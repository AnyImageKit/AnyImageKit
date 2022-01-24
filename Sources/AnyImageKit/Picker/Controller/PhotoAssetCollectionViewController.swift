//
//  PhotoAssetCollectionViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

private let defaultAssetSpacing: CGFloat = 2
private let toolBarHeight: CGFloat = 56

protocol AssetPickerViewControllerDelegate: AnyObject {
    
    func assetPickerDidCancel(_ picker: PhotoAssetCollectionViewController)
    func assetPickerDidFinishPicking(_ picker: PhotoAssetCollectionViewController)
}

final class PhotoAssetCollectionViewController: AnyImageViewController {
    
    weak var delegate: AssetPickerViewControllerDelegate?
    
    private(set) var listPicker: PhotoLibraryListViewController?
    private(set) var photoLibrary: PhotoLibraryAssetCollection?
    private(set) var photoLibraryList: [PhotoLibraryAssetCollection] = []
    
    private var preferredCollectionWidth: CGFloat = .zero
    private var didRegisterPhotoLibraryChangeObserver: Bool = false
    
    lazy var stopReloadAlbum: Bool = false
    
    private(set) lazy var titleView: AssetCollectionTitleButton = makeTitleView()
    private(set) lazy var collectionView: UICollectionView = makeCollectionView()
    private(set) lazy var toolBar: PickerToolBar = makeToolBar()
    private(set) lazy var permissionDeniedView: PermissionDeniedView = makePermissionDeniedView()
    
    let manager: PickerManager
    
    init(manager: PickerManager) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        unregisterPhotoLibraryChangeObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotifications()
        setupNavigation()
        setupView()
        checkPermission()
        update(options: manager.options)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle(style: manager.options.theme.style)
    }
}

// MARK: - PickerOptionsConfigurable
extension PhotoAssetCollectionViewController: PickerOptionsConfigurable {
    
    var childrenConfigurable: [PickerOptionsConfigurable] {
        return preferredChildrenConfigurable + [titleView]
    }
}

// MARK: - Photo Library
extension PhotoAssetCollectionViewController {
    
    private func checkPermission() {
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
        let library = await PhotoLibraryAssetCollection.fetchDefault(options: manager.options)
        setPhotoLibrary(library, reset: true)
        await loadPhotoLibraryList()
    }
    
    private func loadPhotoLibraryList() async {
        let libraryList = await PhotoLibraryAssetCollection.fetchAll(options: manager.options)
        setPhotoLibraryList(libraryList)
    }
    
    private func setPhotoLibrary(_ library: PhotoLibraryAssetCollection, reset: Bool) {
        if reset {
            library.reset()
        }
        photoLibrary = library
        titleView.setTitle(library.localizedTitle)
        toolBar.setEnable(!library.selectedItems.isEmpty)
        collectionView.reloadData()
        scrollToEnd()
    }
    
    private func setPhotoLibraryList(_ libraryList: [PhotoLibraryAssetCollection]) {
        photoLibraryList = libraryList
        if let listPicker = listPicker {
            listPicker.config(library: photoLibrary, libraryList: libraryList)
        }
    }
}

// MARK: - Private function
extension PhotoAssetCollectionViewController {
    
    private func setSelected(_ index: Int) {
        guard let photoLibrary = photoLibrary, let asset = photoLibrary[index].asset else { return }
        
        do {
            try photoLibrary.setSelected(asset: asset)
            updateVisibleCellState(current: index)
            toolBar.setEnable(!photoLibrary.selectedItems.isEmpty)
            trackObserver?.track(event: .pickerSelect, userInfo: [.isOn: asset.state.isSelected, .page: AnyImagePage.pickerAsset])
        } catch {
            if let error = error as? AssetSelectedError<PHAsset> {
                let options = manager.options
                let message: String
                switch error {
                case .maximumOfPhotosOrVideos:
                    message = String(format: options.theme[string: .pickerSelectMaximumOfPhotosOrVideos], options.selectLimit)
                case .maximumOfPhotos:
                    message = String(format: options.theme[string: .pickerSelectMaximumOfPhotos], options.selectLimit)
                case .maximumOfVideos:
                    message = String(format: options.theme[string: .pickerSelectMaximumOfVideos], options.selectLimit)
                case .disabled(let rule):
                    message = rule.alertMessage(for: asset, context: photoLibrary.checker.context)
                }
                self.showAlert(message: message, stringConfig: options.theme)
            }
        }
    }
    
    private func updateVisibleCellState(current index: Int? = nil) {
        guard let photoLibrary = photoLibrary else { return }
        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell), let cell = cell as? PhotoAssetCell, let asset = photoLibrary[indexPath.item].asset {
                cell.updateState(asset, options: manager.options, animated: index == indexPath.item)
            }
        }
    }
    
    private func scrollToEnd(animated: Bool = false) {
        if manager.options.orderByDate == .asc {
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
        Task {
            let controller = PhotoLibraryListViewController(manager: manager)
            controller.config(library: photoLibrary, libraryList: photoLibraryList)
            let presentationController = MenuDropDownPresentationController(presentedViewController: controller, presenting: self)
            let isFullScreen = ScreenHelper.mainBounds.height == (navigationController?.view ?? view).frame.height
            presentationController.isFullScreen = isFullScreen
            presentationController.cornerRadius = 8
            presentationController.corners = [.bottomLeft, .bottomRight]
            controller.transitioningDelegate = presentationController
            self.listPicker = controller
            present(controller, animated: true, completion: nil)
            trackObserver?.track(event: .pickerSwitchAlbum, userInfo: [:])
            
            let result = await controller.pick()
            switch result {
            case .interaction(let newLibrary):
                setPhotoLibrary(newLibrary, reset: true)
            case .cancel:
                break
            }
            
            titleView.isSelected = false
            listPicker = nil
        }
    }
    
    @objc private func cancelButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.assetPickerDidCancel(self)
        trackObserver?.track(event: .pickerCancel, userInfo: [:])
    }
    
    @objc private func previewButtonTapped(_ sender: UIButton) {
        guard let asset = manager.selectedAssets.first else { return }
        let controller = PhotoPreviewController(manager: manager)
        controller.currentIndex = asset.idx
        controller.dataSource = self
        controller.delegate = self
        present(controller, animated: true, completion: nil)
        trackObserver?.track(event: .pickerPreview, userInfo: [:])
    }
    
    @objc private func originalImageButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        manager.useOriginalImage = sender.isSelected
        trackObserver?.track(event: .pickerOriginalImage, userInfo: [.isOn: sender.isSelected, .page: AnyImagePage.pickerAsset])
    }
    
    @objc func doneButtonTapped(_ sender: UIButton) {
        defer { sender.isEnabled = true }
        sender.isEnabled = false
        stopReloadAlbum = true
        delegate?.assetPickerDidFinishPicking(self)
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
        self.collectionView.reloadData()
    }
}

// MARK: - UI
extension PhotoAssetCollectionViewController {
    
    private func setupNavigation() {
        navigationItem.titleView = titleView
        let cancel = UIBarButtonItem(title: manager.options.theme[string: .cancel], style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
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
        let hideToolBar = manager.options.selectionTapAction.hideToolBar && manager.options.selectLimit == 1
        view.contentInset = UIEdgeInsets(top: defaultAssetSpacing,
                                         left: defaultAssetSpacing,
                                         bottom: defaultAssetSpacing + (hideToolBar ? 0 : toolBarHeight),
                                         right: defaultAssetSpacing)
        view.backgroundColor = manager.options.theme[color: .background]
        view.registerCell(PhotoAssetCell.self)
        view.registerCell(CameraCell.self)
        view.dataSource = self
        view.delegate = self
        return view
    }
    
    private func makeToolBar() -> PickerToolBar {
        let view = PickerToolBar(style: .picker)
        view.setEnable(false)
        view.leftButton.addTarget(self, action: #selector(previewButtonTapped(_:)), for: .touchUpInside)
        view.originalButton.isSelected = manager.useOriginalImage
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
            let hideToolBar = manager.options.selectionTapAction.hideToolBar && manager.options.selectLimit == 1
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
        case .prefix(let addition), .suffix(let addition):
            print(addition)
            let cell = collectionView.dequeueReusableCell(CameraCell.self, for: indexPath)
            cell.update(options: manager.options)
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = .button
            cell.accessibilityLabel = manager.options.theme[string: .pickerTakePhoto]
            return cell
        case .asset(let asset):
            let cell = collectionView.dequeueReusableCell(PhotoAssetCell.self, for: indexPath)
            cell.tag = indexPath.item
            cell.setContent(asset, options: manager.options)
            cell.selectEvent.delegate(on: self) { (self, _) in
                self.setSelected(indexPath.item)
            }
            cell.backgroundColor = UIColor.white
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = .button
            let accessibilityLabel = manager.options.theme[string: asset.mediaType == .video ? .video : .photo]
            cell.accessibilityLabel = "\(accessibilityLabel)\(indexPath.row)"
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoAssetCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let album = album else { return }
//        let asset = album.assets[indexPath.item]
//
//        #if ANYIMAGEKIT_ENABLE_CAPTURE
//        if asset.isCamera { // 点击拍照 Item
//            showCapture()
//            return
//        }
//        #endif
//        #if ANYIMAGEKIT_ENABLE_EDITOR
//        if manager.options.selectionTapAction == .openEditor && canOpenEditor(with: asset) {
//            openEditor(with: asset, indexPath: indexPath)
//            return
//        }
//        #endif
//
//        if manager.options.selectionTapAction == .quickPick {
//            guard let cell = collectionView.cellForItem(at: indexPath) as? AssetCell else { return }
//            cell.selectEvent.call()
//            if manager.options.selectLimit == 1 && manager.selectedAssets.count == 1 {
//                doneButtonTapped(toolBar.doneButton)
//            }
//        } else if case .disable(let rule) = asset.state {
//            let message = rule.alertMessage(for: asset, assetList: manager.selectedAssets)
//            showAlert(message: message, stringConfig: manager.options.theme)
//            return
//        } else if !asset.isSelected && manager.isUpToLimit {
//            return
//        } else {
//            let controller = PhotoPreviewController(manager: manager)
//            controller.currentIndex = indexPath.item - itemOffset
//            controller.dataSource = self
//            controller.delegate = self
//            present(controller, animated: true, completion: nil)
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let asset = album?.assets[indexPath.item] else { return }
//        if let cell = cell as? AssetCell {
//            cell.updateState(asset, manager: manager, animated: false)
//        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoAssetCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contentSize = collectionView.bounds.inset(by: collectionView.contentInset).size
        let columnNumber: CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone || !manager.options.autoCalculateColumnNumber {
            columnNumber = CGFloat(manager.options.columnNumber)
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
    
    func numberOfPhotos(in controller: PhotoPreviewController) -> Int {
        guard let photoLibrary = photoLibrary else { return 0 }
        return photoLibrary.assetCount
    }
    
    func previewController(_ controller: PhotoPreviewController, assetOfIndex index: Int) -> PreviewData {
        let idx = index //+ itemOffset
        let indexPath = IndexPath(item: idx, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as? PhotoAssetCell
        fatalError()
//        return (cell?.image, album!.assets[idx])
    }
    
    func previewController(_ controller: PhotoPreviewController, thumbnailViewForIndex index: Int) -> UIView? {
        let idx = index //+ itemOffset
        let indexPath = IndexPath(item: idx, section: 0)
        return collectionView.cellForItem(at: indexPath) ?? toolBar.leftButton
    }
}

// MARK: - PhotoPreviewControllerDelegate
extension PhotoAssetCollectionViewController: PhotoPreviewControllerDelegate {
    
    func previewController(_ controller: PhotoPreviewController, didSelected index: Int) {
        updateVisibleCellState()
        toolBar.setEnable(true)
    }
    
    func previewController(_ controller: PhotoPreviewController, didDeselected index: Int) {
        updateVisibleCellState()
        toolBar.setEnable(!manager.selectedAssets.isEmpty)
    }
    
    func previewController(_ controller: PhotoPreviewController, useOriginalImage: Bool) {
        toolBar.originalButton.isSelected = useOriginalImage
    }
    
    func previewControllerDidClickDone(_ controller: PhotoPreviewController) {
        stopReloadAlbum = true
        delegate?.assetPickerDidFinishPicking(self)
    }
    
    func previewControllerWillDisappear(_ controller: PhotoPreviewController) {
        let idx = controller.currentIndex //+ itemOffset
        let indexPath = IndexPath(item: idx, section: 0)
        collectionView.reloadData()
        if !(collectionView.visibleCells.map{ $0.tag }).contains(idx) {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
    }
}
