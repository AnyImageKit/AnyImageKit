//
//  PhotoAssetCollectionViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos
import Combine

private let defaultAssetSpacing: CGFloat = 2
private let toolBarHeight: CGFloat = 56

final class PhotoAssetCollectionViewController: AnyImageViewController, PickerOptionsConfigurableContent {
    
    private var didRegisterPhotoLibraryChangeObserver: Bool = false
    
    private var photoLibraryListCancellable: AnyCancellable?
    private var photoLibraryListViewController: PhotoLibraryListViewController?
    private var photoLibrary: PhotoLibraryAssetCollection?
    private var photoLibraryList: [PhotoLibraryAssetCollection] = []
    
    private lazy var titleView: AssetCollectionTitleButton = makeTitleView()
    private lazy var collectionView: UICollectionView = makeCollectionView()
    private lazy var toolBar: PickerToolBar = makeToolBar()
    private lazy var permissionDeniedView: PermissionDeniedView = makePermissionDeniedView()
    
    private var continuation: CheckedContinuation<UserAction<PhotoLibraryAssetCollection>, Never>?
    
    let pickerContext: PickerOptionsConfigurableContext = .init()
    
    deinit {
        unregisterPhotoLibraryChangeObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotifications()
        setupNavigation()
        setupView()
        setupDataBinding()
        loadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle(style: options.theme.style)
    }
}
 
// MARK: PickerOptionsConfigurableContent
extension PhotoAssetCollectionViewController {
    
    func update(options: PickerOptionsInfo) {
        let hideToolBar = options.selectionTapAction.hideToolBar && options.selectLimit == 1
        collectionView.contentInset = UIEdgeInsets(top: defaultAssetSpacing,
                                                   left: defaultAssetSpacing,
                                                   bottom: defaultAssetSpacing + (hideToolBar ? 0 : toolBarHeight),
                                                   right: defaultAssetSpacing)
        collectionView.backgroundColor = options.theme[color: .background]
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: Concurrency
extension PhotoAssetCollectionViewController {
    
    func pick() async -> UserAction<PhotoLibraryAssetCollection> {
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
    
    private func resume(result: UserAction<PhotoLibraryAssetCollection>) {
        if let continuation = continuation {
            continuation.resume(returning: result)
            self.continuation = nil
        }
    }
}

// MARK: - Photo Library
extension PhotoAssetCollectionViewController {
    
    private func loadData() {
        Task {
            let status = await check(permission: .photos)
            switch status {
            case .authorized:
                registerPhotoLibraryChangeObserver()
                await loadPhotoLibrary()
            case .limited:
                registerPhotoLibraryChangeObserver()
                addPermissionLimitedView()
                await loadPhotoLibrary()
            case .denied:
                addPermissionDeniedView()
            }
        }
    }
    
    private func loadPhotoLibrary() async {
        let library = await PhotoLibraryAssetCollection.fetchDefault(options: options)
        setPhotoLibrary(library)
        await loadPhotoLibraryList()
    }
    
    private func loadPhotoLibraryList() async {
        let libraryList = await PhotoLibraryAssetCollection.fetchAll(options: options)
        setPhotoLibraryList(libraryList)
    }
    
    private func setPhotoLibrary(_ library: PhotoLibraryAssetCollection) {
        photoLibrary = library
        for plugin in library.plugins {
            plugin.register(.init(collectionView: collectionView))
        }
        titleView.setTitle(library.localizedTitle)
        toolBar.setEnable(!library.selectedItems.isEmpty)
        collectionView.reloadData()
        scrollToEnd()
    }
    
    private func setPhotoLibraryList(_ libraryList: [PhotoLibraryAssetCollection]) {
        photoLibraryList = libraryList
        if let listPicker = photoLibraryListViewController {
            listPicker.config(library: photoLibrary, libraryList: libraryList)
        }
    }
}

// MARK: - Private function
extension PhotoAssetCollectionViewController {
    
    func setSelected(_ index: Int) {
        guard let photoLibrary = photoLibrary, let asset = photoLibrary[index].asset else { return }
        
        do {
            try photoLibrary.setSelected(asset: asset)
            updateVisibleCellState(current: index)
            toolBar.setEnable(!photoLibrary.selectedItems.isEmpty)
            trackObserver?.track(event: .pickerSelect, userInfo: [.isOn: asset.state.isSelected, .page: AnyImagePage.pickerAsset])
        } catch {
            if let error = error as? AssetSelectedError<PHAsset> {
                let message: String
                switch error {
                case .maximumOfPhotosOrVideos:
                    message = String(format: options.theme[string: .pickerSelectMaximumOfPhotosOrVideos], options.selectLimit)
                case .maximumOfPhotos:
                    message = String(format: options.theme[string: .pickerSelectMaximumOfPhotos], options.selectLimit)
                case .maximumOfVideos:
                    message = String(format: options.theme[string: .pickerSelectMaximumOfVideos], options.selectLimit)
                case .disabled(let rule):
                    message = rule.disabledMessage(for: asset, context: photoLibrary.checker.context)
                }
                self.showAlert(message: message, stringConfig: options.theme)
            }
        }
    }
    
    private func updateVisibleCellState(current index: Int? = nil) {
        guard let photoLibrary = photoLibrary else { return }
        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell), let cell = cell as? PhotoAssetCell, let asset = photoLibrary[indexPath.item].asset {
                cell.updateState(asset: asset, animated: index == indexPath.item)
                cell.update(options: options)
            }
        }
    }
    
    private func scrollToEnd(animated: Bool = false) {
        if options.orderByDate == .asc {
            collectionView.scrollToLast(at: .bottom, animated: animated)
        } else {
            collectionView.scrollToFirst(at: .top, animated: animated)
        }
    }
}

// MARK: - Notification
extension PhotoAssetCollectionViewController {
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(containerSizeDidChange(_:)), name: .containerSizeDidChange, object: nil)
    }
    
    @objc private func containerSizeDidChange(_ sender: Notification) {
        guard collectionView.visibleCells.count > 0 else { return }
        let visibleCellRows = collectionView.visibleCells.map{ $0.tag }.sorted()
        let row = visibleCellRows[visibleCellRows.count / 2]
        let indexPath = IndexPath(row: row, section: 0)
        collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
    }
}

// MARK: - Action
extension PhotoAssetCollectionViewController {
    
    @objc private func titleViewTapped(_ sender: AssetCollectionTitleButton) {
        trackObserver?.track(event: .pickerSwitchAlbum, userInfo: [:])
        Task {
            let controller = PhotoLibraryListViewController()
            controller.config(library: photoLibrary, libraryList: photoLibraryList)
            photoLibraryListCancellable = assign(on: controller)
            photoLibraryListViewController = controller
            
            let presentationController = MenuDropDownPresentationController(presentedViewController: controller, presenting: self)
            let isFullScreen = ScreenHelper.mainBounds.height == (navigationController?.view ?? view).frame.height
            presentationController.isFullScreen = isFullScreen
            presentationController.cornerRadius = 8
            presentationController.corners = [.bottomLeft, .bottomRight]
            controller.transitioningDelegate = presentationController
            
            present(controller, animated: true, completion: nil)
            
            let userAction = await controller.pick()
            switch userAction {
            case .interaction(let newLibrary):
                setPhotoLibrary(newLibrary)
            case .cancel:
                break
            }
            
            titleView.isSelected = false
            photoLibraryListViewController = nil
            photoLibraryListCancellable = nil
        }
    }
    
    @objc private func cancelButtonTapped(_ sender: UIBarButtonItem) {
        resume(result: .cancel)
        trackObserver?.track(event: .pickerCancel, userInfo: [:])
    }
    
    @objc private func previewButtonTapped(_ sender: UIButton) {
        guard let photoLibrary = photoLibrary, let asset = photoLibrary.selectedItems.first, let index = photoLibrary.loadAssetIndex(for: asset) else { return }
        let controller = PhotoPreviewController(photoLibrary: photoLibrary)
        controller.assetIndex = index
        controller.dataSource = self
        controller.delegate = self
        present(controller, animated: true, completion: nil)
        trackObserver?.track(event: .pickerPreview, userInfo: [:])
    }
    
    @objc private func originalImageButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.options.useOriginalImage = sender.isSelected
        trackObserver?.track(event: .pickerOriginalImage, userInfo: [.isOn: sender.isSelected, .page: AnyImagePage.pickerAsset])
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        defer { sender.isEnabled = true }
        sender.isEnabled = false
        guard let photoLibrary = photoLibrary else { return }
        resume(result: .interaction(photoLibrary))
        trackObserver?.track(event: .pickerDone, userInfo: [.page: AnyImagePage.pickerAsset])
    }
    
    @objc private func limitedButtonTapped(_ sender: UIButton) {
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            trackObserver?.track(event: .pickerLimitedLibrary, userInfo: [:])
        }
    }
}

// MARK: - Register PHPhotoLibraryChangeObserver
extension PhotoAssetCollectionViewController {
    
    /// After iOS 15.2/Xcode 13.2, you must register PhotoLibraryChangeObserver after authorized Photo permission
    private func registerPhotoLibraryChangeObserver() {
        guard !didRegisterPhotoLibraryChangeObserver else { return }
        PHPhotoLibrary.shared().register(self)
        didRegisterPhotoLibraryChangeObserver = true
    }
    
    private func unregisterPhotoLibraryChangeObserver() {
        guard didRegisterPhotoLibraryChangeObserver else { return }
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        didRegisterPhotoLibraryChangeObserver = false
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension PhotoAssetCollectionViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let photoLibrary = photoLibrary, let changeDetails = changeInstance.changeDetails(for: photoLibrary.fetchResult.phFetchResult) else { return }
        
        let fetchResult = FetchResult(changeDetails.fetchResultAfterChanges)
        self.photoLibrary?.update(fetchResult: fetchResult)
        Thread.runOnMain {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UI
extension PhotoAssetCollectionViewController {
    
    private func setupNavigation() {
        navigationItem.titleView = titleView
        let cancel = UIBarButtonItem(title: options.theme[string: .cancel], style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.leftBarButtonItem = cancel
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        view.addSubview(toolBar)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        toolBar.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-toolBarHeight)
            maker.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupDataBinding() {
        // FIXME:
//        assign(on: titleView).store(in: &cancellables)
        sink().store(in: &cancellables)
    }
    
    private func makeTitleView() -> AssetCollectionTitleButton {
        let view = AssetCollectionTitleButton(frame: CGRect(x: 0, y: 0, width: 180, height: 32))
        view.addTarget(self, action: #selector(titleViewTapped(_:)), for: .touchUpInside)
        return view
    }
    
    private func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = defaultAssetSpacing
        layout.minimumInteritemSpacing = defaultAssetSpacing
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.alwaysBounceVertical = true
        view.contentInsetAdjustmentBehavior = .automatic
        view.registerCell(PhotoAssetCell.self)
        view.dataSource = self
        view.delegate = self
        return view
    }
    
    private func makeToolBar() -> PickerToolBar {
        let view = PickerToolBar(style: .picker)
        view.setEnable(false)
        view.leftButton.addTarget(self, action: #selector(previewButtonTapped(_:)), for: .touchUpInside)
        view.originalButton.isSelected = options.useOriginalImage
        view.originalButton.addTarget(self, action: #selector(originalImageButtonTapped(_:)), for: .touchUpInside)
        view.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        view.permissionLimitedView.limitedButton.addTarget(self, action: #selector(limitedButtonTapped(_:)), for: .touchUpInside)
        return view
    }
    
    private func makePermissionDeniedView() -> PermissionDeniedView {
        let view = PermissionDeniedView(frame: .zero)
        return view
    }
    
    private func addPermissionLimitedView() {
        if #available(iOS 14.0, *) {
            let hideToolBar = options.selectionTapAction.hideToolBar && options.selectLimit == 1
            let newToolBarHeight = (hideToolBar ? 0 : toolBarHeight) + toolBar.limitedViewHeight
            toolBar.isHidden = false
            toolBar.contentView.isHidden = hideToolBar
            toolBar.snp.updateConstraints { update in
                update.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-newToolBarHeight)
            }
            toolBar.showLimitedView()
            collectionView.contentInset.bottom = defaultAssetSpacing + newToolBarHeight
        }
    }
    
    private func addPermissionDeniedView() {
        view.addSubview(permissionDeniedView)
        permissionDeniedView.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            maker.left.right.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoAssetCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoLibrary?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let photoLibrary = photoLibrary else { return UICollectionViewCell() }
        let element = photoLibrary[indexPath.item]
        switch element {
        case .prefix(let plugin), .suffix(let plugin):
            let cell = plugin.dequeue(.init(collectionView: collectionView, indexPath: indexPath))
            listCancellables[indexPath] = assign(on: cell)
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = .button
            return cell
        case .asset(let asset):
            let cell = collectionView.dequeueReusableCell(PhotoAssetCell.self, for: indexPath)
            listCancellables[indexPath] = assign(on: cell)
            cell.setContent(asset: asset)
            cell.selectEvent.delegate(on: self) { (self, _) in
                self.setSelected(indexPath.item)
            }
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = .button
            let accessibilityLabel = options.theme[string: asset.mediaType.isVideo ? .video : .photo]
            cell.accessibilityLabel = "\(accessibilityLabel)\(indexPath.row)"
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoAssetCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photoLibrary = photoLibrary else { return }
        let element = photoLibrary[indexPath.item]
        switch element {
        case .prefix(let plugin), .suffix(let plugin):
            plugin.select(.init(collectionView: collectionView, controller: self))
        case .asset(let asset):
            #if ANYIMAGEKIT_ENABLE_EDITOR
            if options.selectionTapAction == .openEditor {
                if let rule = asset.state.disableCheckRule {
                    let message = rule.disabledMessage(for: asset, context: photoLibrary.checker.context)
                    showAlert(message: message, stringConfig: options.theme)
                } else if asset.mediaType == .photo && options.editorOptions.contains(.photo) {
                    openEditor(asset: asset, indexPath: indexPath)
                } else if asset.phAsset.mediaType == .video && options.editorOptions.contains(.video) {
                    openEditor(asset: asset, indexPath: indexPath)
                }
                return
            }
            #endif
            openPreview(asset: asset, indexPath: indexPath)
        }
    }
    
    private func openPreview(asset: Asset<PHAsset>, indexPath: IndexPath) {
        guard let photoLibrary = photoLibrary else { return }
        if options.selectionTapAction == .quickPick {
            setSelected(indexPath.item)
            if options.selectLimit == 1 && photoLibrary.selectedItems.count == 1 {
                doneButtonTapped(toolBar.doneButton)
            }
        } else if let rule = asset.state.disableCheckRule {
            let message = rule.disabledMessage(for: asset, context: photoLibrary.checker.context)
            showAlert(message: message, stringConfig: options.theme)
            return
        } else if !asset.isSelected && photoLibrary.checker.isUpToLimit {
            return
        } else if let cell = collectionView.cellForItem(at: indexPath) as? PhotoAssetCell {
            let controller = PhotoPreviewController(photoLibrary: photoLibrary)
            let assetIndex = photoLibrary.convertIndexToAssetIndex(indexPath.item)
            controller.presentationScaleImage = cell.displayImage
            controller.assetIndex = assetIndex
            controller.dataSource = self
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoAssetCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contentSize = collectionView.bounds.inset(by: collectionView.contentInset).size
        let columnNumber: CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone || !options.autoCalculateColumnNumber {
            columnNumber = CGFloat(options.columnNumber)
        } else {
            let minWidth: CGFloat = 140
            columnNumber = max(CGFloat(Int(contentSize.width / minWidth)), 3)
        }
        let width = floor((contentSize.width-(columnNumber-1)*defaultAssetSpacing)/columnNumber)
        return CGSize(width: width, height: width)
    }
}

// MARK: - PhotoPreviewControllerDataSource
extension PhotoAssetCollectionViewController: PhotoPreviewControllerDataSource {
    
    func previewController(_ controller: PhotoPreviewController, thumbnailViewForIndex assetIndex: Int) -> UIImageView? {
        guard let photoLibrary = photoLibrary else { return nil }
        let index = photoLibrary.convertAssetIndexToIndex(assetIndex)
        let indexPath = IndexPath(item: index, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as? PhotoAssetCell
        return cell?.displayContentView
    }
}

// MARK: - PhotoPreviewControllerDelegate
extension PhotoAssetCollectionViewController: PhotoPreviewControllerDelegate {
    
    func previewController(_ controller: PhotoPreviewController, didSelected index: Int) {
        updateVisibleCellState()
        toolBar.setEnable(true)
    }
    
    func previewController(_ controller: PhotoPreviewController, didDeselected index: Int) {
        guard let photoLibrary = photoLibrary else { return }
        updateVisibleCellState()
        toolBar.setEnable(!photoLibrary.selectedItems.isEmpty)
    }
    
    func previewController(_ controller: PhotoPreviewController, useOriginalImage: Bool) {
        toolBar.originalButton.isSelected = useOriginalImage
    }
    
    func previewControllerDidClickDone(_ controller: PhotoPreviewController) {
        guard let photoLibrary = photoLibrary else { return }
        resume(result: .interaction(photoLibrary))
    }
    
    func previewControllerWillDisappear(_ controller: PhotoPreviewController) {
        guard let photoLibrary = photoLibrary else { return }
        let assetIndex = controller.assetIndex
        let index = photoLibrary.convertAssetIndexToIndex(assetIndex)
        let indexPath = IndexPath(item: index, section: 0)
        if !(collectionView.visibleCells.map{ $0.tag }).contains(index) {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
    }
}
