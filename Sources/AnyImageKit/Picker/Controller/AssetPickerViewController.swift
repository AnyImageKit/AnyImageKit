//
//  AssetPickerViewController.swift
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
    
    func assetPickerDidCancel(_ picker: AssetPickerViewController)
    func assetPickerDidFinishPicking(_ picker: AssetPickerViewController)
}

final class AssetPickerViewController: AnyImageViewController {
    
    weak var delegate: AssetPickerViewControllerDelegate?
    
    private(set) var albumsPicker: AlbumPickerViewController?
    private(set) var album: Album?
    private(set) var albums = [Album]()
    
    private var preferredCollectionWidth: CGFloat = .zero
    private var autoScrollToLatest: Bool = false
    private var didRegisterPhotoLibraryChangeObserver: Bool = false
    private var containerSize: CGSize = ScreenHelper.mainBounds.size
    
    #if swift(>=5.5)
    private var _dataSource: Any?
    @available(iOS 14.0, *)
    private var dataSource: UICollectionViewDiffableDataSource<Section, Asset> {
        get {
            if _dataSource == nil {
                _dataSource = UICollectionViewDiffableDataSource<Section, Asset>(collectionView: collectionView) { (collectionView, indexPath, asset) -> UICollectionViewCell? in
                    return nil
                }
            }
            return _dataSource as! UICollectionViewDiffableDataSource<Section, Asset>
        }
        set {
            _dataSource = newValue
        }
    }
    #else
    @available(iOS 14.0, *)
    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, Asset>()
    #endif
    
    lazy var stopReloadAlbum: Bool = false
    
    private lazy var titleView: PickerArrowButton = {
        let view = PickerArrowButton(frame: CGRect(x: 0, y: 0, width: 180, height: 32))
        view.addTarget(self, action: #selector(titleViewTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
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
        if #available(iOS 14.0, *) {
            
        } else {
            view.registerCell(AssetCell.self)
            view.registerCell(CameraCell.self)
            view.dataSource = self
        }
        view.delegate = self
        return view
    }()
    
    private(set) lazy var toolBar: PickerToolBar = {
        let view = PickerToolBar(style: .picker)
        view.setEnable(false)
        view.leftButton.addTarget(self, action: #selector(previewButtonTapped(_:)), for: .touchUpInside)
        view.originalButton.isSelected = manager.useOriginalImage
        view.originalButton.addTarget(self, action: #selector(originalImageButtonTapped(_:)), for: .touchUpInside)
        view.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        view.permissionLimitedView.limitedButton.addTarget(self, action: #selector(limitedButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private lazy var permissionView: PermissionDeniedView = {
        let view = PermissionDeniedView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    private var itemOffset: Int {
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        switch manager.options.orderByDate {
        case .asc:
            return 0
        case .desc:
            guard !manager.options.captureOptions.mediaOptions.isEmpty else { return 0 }
            return ((album?.hasCamera ?? false) ? 1 : 0)
        }
        #else
        return 0
        #endif
    }
    
    private weak var previewController: PhotoPreviewController?
    
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
        if #available(iOS 14.0, *) {
            setupDataSource()
        }
        checkPermission()
        update(options: manager.options)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if autoScrollToLatest {
            scrollToEnd()
            autoScrollToLatest = false
        }
    }
    
    private func setupNavigation() {
        navigationItem.titleView = titleView
        let cancel = UIBarButtonItem(title: manager.options.theme[string: .cancel], style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.leftBarButtonItem = cancel
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        view.addSubview(toolBar)
        view.addSubview(permissionView)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        toolBar.snp.makeConstraints { maker in
            if #available(iOS 11.0, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-toolBarHeight)
            } else {
                maker.top.equalTo(bottomLayoutGuide.snp.top).offset(-toolBarHeight)
            }
            maker.left.right.bottom.equalToSuperview()
        }
        permissionView.snp.makeConstraints { maker in
            if #available(iOS 11.0, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            } else {
                maker.top.equalTo(topLayoutGuide.snp.bottom).offset(20)
            }
            maker.left.right.bottom.equalToSuperview()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle(style: manager.options.theme.style)
    }
}

// MARK: - PickerOptionsConfigurable
extension AssetPickerViewController: PickerOptionsConfigurable {
    
    var childrenConfigurable: [PickerOptionsConfigurable] {
        return preferredChildrenConfigurable + [titleView]
    }
}

// MARK: - Private function
extension AssetPickerViewController {
    
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
    
    private func checkPermission() {
        check(permission: .photos, authorized: { [weak self] in
            guard let self = self else { return }
            self.registerPhotoLibraryChangeObserver()
            self.loadDefaultAlbumIfNeeded()
        }, limited: { [weak self] in
            guard let self = self else { return }
            self.registerPhotoLibraryChangeObserver()
            self.loadDefaultAlbumIfNeeded()
            self.showLimitedView()
        }, denied: { [weak self] _ in
            guard let self = self else { return }
            self.permissionView.isHidden = false
        })
    }
    
    private func loadDefaultAlbumIfNeeded() {
        guard album == nil else { return }
        manager.fetchCameraRollAlbum { [weak self] album in
            guard let self = self else { return }
            self.setAlbum(album)
            self.preselectAssets()
            self.reloadData(animated: false)
            self.scrollToEnd()
            self.autoScrollToLatest = true
            self.preLoadAlbums()
        }
    }
    
    private func preLoadAlbums() {
        manager.fetchAllAlbums { [weak self] albums in
            guard let self = self else { return }
            self.setAlbums(albums)
        }
    }
    
    private func setAlbum(_ album: Album) {
        guard self.album != album else { return }
        self.album = album
        titleView.setTitle(album.title)
        manager.removeAllSelectedAsset()
        manager.cancelAllFetch()
        toolBar.setEnable(false)
        album.assets.forEach { $0.state = .unchecked }
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        addCameraAssetIfNeeded()
        #endif
    }
    
    private func setAlbums(_ albums: [Album]) {
        self.albums = albums.filter{ !$0.assets.isEmpty }
        if let albumsPicker = albumsPicker {
            albumsPicker.albums = albums
            albumsPicker.reloadData()
        }
    }
    
    private func reloadAlbums() {
        manager.fetchAllAlbums { [weak self] albums in
            guard let self = self else { return }
            self.setAlbums(albums)
            if let identifier = self.album?.identifier {
                if let idx = (albums.firstIndex { $0.identifier == identifier }) {
                    self.updateAlbum(albums[idx])
                }
            }
        }
    }
    
    private func reloadAlbum(_ album: Album) {
        guard !stopReloadAlbum else { return }
        manager.fetchAlbum(album) { [weak self] newAlbum in
            guard let self = self else { return }
            self.updateAlbum(newAlbum)
            self.preLoadAlbums()
        }
    }
    
    private func updateAlbum(_ album: Album) {
        // Update selected assets when album assets changed
        for asset in manager.selectedAssets.reversed() {
            if !(album.assets.contains { $0 == asset }) {
                manager.removeSelectedAsset(asset)
            }
        }
        for asset in manager.selectedAssets {
            if let idx = (album.assets.firstIndex { $0 == asset }) {
                manager.removeSelectedAsset(asset)
                manager.addSelectedAsset(album.assets[idx])
            }
        }
        toolBar.setEnable(!manager.selectedAssets.isEmpty)
        
        self.album = album
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        addCameraAssetIfNeeded()
        #endif
        reloadData()
        if manager.options.orderByDate == .asc {
            collectionView.scrollToLast(at: .bottom, animated: true)
        } else {
            collectionView.scrollToFirst(at: .top, animated: true)
        }
    }
    
    private func showLimitedView() {
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
    
    func updateVisibleCellState(_ animatedItem: Int = -1) {
        guard let album = album else { return }
        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell), let cell = cell as? AssetCell {
                cell.updateState(album.assets[indexPath.item], manager: manager, animated: animatedItem == indexPath.item)
            }
        }
    }
    
    private func preselectAssets() {
        let preselectAssets = manager.options.preselectAssets
        var selectedAssets: [Asset] = []
        if preselectAssets.isEmpty { return }
        for asset in (album?.assets ?? []).reversed() {
            if preselectAssets.contains(asset.identifier) {
                selectedAssets.append(asset)
                if selectedAssets.count == preselectAssets.count {
                    break
                }
            }
        }
        for identifier in preselectAssets {
            if let asset = (selectedAssets.filter{ $0.identifier == identifier }).first {
                manager.addSelectedAsset(asset)
            }
        }
        toolBar.setEnable(!manager.selectedAssets.isEmpty)
    }
    
    private func scrollToEnd(animated: Bool = false) {
        if manager.options.orderByDate == .asc {
            collectionView.scrollToLast(at: .bottom, animated: animated)
        } else {
            collectionView.scrollToFirst(at: .top, animated: animated)
        }
    }
    
    func selectItem(_ idx: Int) {
        guard let album = album else { return }
        let asset = album.assets[idx]
        
        if !asset.isSelected {
            let result = manager.addSelectedAsset(asset)
            if !result.success && !result.message.isEmpty {
                showAlert(message: result.message, stringConfig: manager.options.theme)
            }
        } else {
            manager.removeSelectedAsset(asset)
        }
        updateVisibleCellState(idx)
        
        toolBar.setEnable(!manager.selectedAssets.isEmpty)
        trackObserver?.track(event: .pickerSelect, userInfo: [.isOn: asset.isSelected, .page: AnyImagePage.pickerAsset])
    }
}

// MARK: - Notification
extension AssetPickerViewController {
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(containerSizeDidChange(_:)), name: .containerSizeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSyncAsset(_:)), name: .didSyncAsset, object: nil)
    }
    
    @objc private func containerSizeDidChange(_ sender: Notification) {
        containerSize = (sender.userInfo?[containerSizeKey] as? CGSize) ?? ScreenHelper.mainBounds.size
        guard collectionView.visibleCells.count > 0 else { return }
        let visibleCellRows = collectionView.visibleCells.map{ $0.tag }.sorted()
        let row = visibleCellRows[visibleCellRows.count / 2]
        let indexPath = IndexPath(row: row, section: 0)
        reloadData(animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
    }
    
    @objc private func didSyncAsset(_ sender: Notification) {
        DispatchQueue.main.async {
            guard let _ = sender.object as? String else { return }
            guard self.manager.options.selectLimit == 1 && self.manager.options.selectionTapAction.hideToolBar else { return }
            guard let asset = self.manager.selectedAssets.first else { return }
            guard let cell = self.collectionView.cellForItem(at: IndexPath(row: asset.idx, section: 0)) as? AssetCell else { return }
            cell.selectEvent.call()
        }
    }
}

// MARK: - Target
extension AssetPickerViewController {
    
    @objc private func titleViewTapped(_ sender: PickerArrowButton) {
        let controller = AlbumPickerViewController(manager: manager)
        controller.album = album
        controller.albums = albums
        controller.delegate = self
        let presentationController = MenuDropDownPresentationController(presentedViewController: controller, presenting: self)
        let isFullScreen = ScreenHelper.mainBounds.height == (navigationController?.view ?? view).frame.height
        presentationController.isFullScreen = isFullScreen
        presentationController.cornerRadius = 8
        presentationController.corners = [.bottomLeft, .bottomRight]
        controller.transitioningDelegate = presentationController
        self.albumsPicker = controller
        present(controller, animated: true, completion: nil)
        trackObserver?.track(event: .pickerSwitchAlbum, userInfo: [:])
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

// MARK: - PHPhotoLibraryChangeObserver
extension AssetPickerViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let album = album, let changeDetails = changeInstance.changeDetails(for: album.fetchResult) else { return }
        
        if #available(iOS 14.0, *), Permission.photos.status == .limited {
            reloadAlbum(album)
            return
        } else {
            guard changeDetails.hasIncrementalChanges else { return }
        }
        
        // Check Insert
        let insertedObjects = changeDetails.insertedObjects
        if !insertedObjects.isEmpty {
            reloadAlbum(album)
            return
        }
        // Check Remove
        let removedObjects = changeDetails.removedObjects
        if !removedObjects.isEmpty {
            reloadAlbum(album)
            return
        }
        // Check Change
        let changedObjects = changeDetails.changedObjects.filter{ changeInstance.changeDetails(for: $0)?.assetContentChanged == true }
        if !changedObjects.isEmpty {
            reloadAlbum(album)
            return
        }
    }
}

// MARK: - UICollectionViewDataSource
extension AssetPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album?.assets.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = album?.assets[indexPath.item] else { return UICollectionViewCell() }
        
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        if asset.isCamera {
            let cell = collectionView.dequeueReusableCell(CameraCell.self, for: indexPath)
            cell.update(options: manager.options)
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = .button
            cell.accessibilityLabel = manager.options.theme[string: .pickerTakePhoto]
            return cell
        }
        #endif
        
        let cell = collectionView.dequeueReusableCell(AssetCell.self, for: indexPath)
        cell.tag = indexPath.row
        cell.setContent(asset, manager: manager)
        cell.selectEvent.delegate(on: self) { (self, _) in
            self.selectItem(indexPath.row)
        }
        cell.backgroundColor = UIColor.white
        cell.isAccessibilityElement = true
        cell.accessibilityTraits = .button
        let accessibilityLabel = manager.options.theme[string: asset.mediaType == .video ? .video : .photo]
        cell.accessibilityLabel = "\(accessibilityLabel)\(indexPath.row)"
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension AssetPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset: Asset
        if #available(iOS 14.0, *) {
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            asset = item
        } else {
            guard let album = album else { return }
            asset = album.assets[indexPath.item]
        }
        
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        if asset.isCamera { // 点击拍照 Item
            showCapture()
            return
        }
        #endif
        #if ANYIMAGEKIT_ENABLE_EDITOR
        if manager.options.selectionTapAction == .openEditor && canOpenEditor(with: asset) {
            openEditor(with: asset, indexPath: indexPath)
            return
        }
        #endif
        
        if manager.options.selectionTapAction == .quickPick {
            guard let cell = collectionView.cellForItem(at: indexPath) as? AssetCell else { return }
            cell.selectEvent.call()
            if manager.options.selectLimit == 1 && manager.selectedAssets.count == 1 {
                doneButtonTapped(toolBar.doneButton)
            }
        } else if case .disable(let rule) = asset.state {
            let message = rule.alertMessage(for: asset, assetList: manager.selectedAssets)
            showAlert(message: message, stringConfig: manager.options.theme)
            return
        } else if !asset.isSelected && manager.isUpToLimit {
            return
        } else {
            let controller = PhotoPreviewController(manager: manager)
            self.previewController = controller
            controller.currentIndex = indexPath.item - itemOffset
            controller.dataSource = self
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let asset = album?.assets[indexPath.item], !asset.isCamera else { return }
        if let cell = cell as? AssetCell {
            cell.updateState(asset, manager: manager, animated: false)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AssetPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxSize = CGRect(origin: .zero, size: containerSize).inset(by: collectionView.contentInset).size
        let columnNumber: CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone || !manager.options.autoCalculateColumnNumber {
            columnNumber = CGFloat(manager.options.columnNumber)
        } else {
            let minWidth: CGFloat = 135
            columnNumber = max(CGFloat(Int(maxSize.width / minWidth)), 3)
        }
        let width = floor((maxSize.width-(columnNumber-1)*defaultAssetSpacing)/columnNumber)
        return CGSize(width: width, height: width)
    }
}

// MARK: - AlbumPickerViewControllerDelegate
extension AssetPickerViewController: AlbumPickerViewControllerDelegate {
    
    func albumPicker(_ picker: AlbumPickerViewController, didSelected album: Album) {
        setAlbum(album)
        reloadData(animated: false)
        scrollToEnd()
    }
    
    func albumPickerWillDisappear(_ picker: AlbumPickerViewController) {
        titleView.isSelected = false
        albumsPicker = nil
    }
}

// MARK: - PhotoPreviewControllerDataSource
extension AssetPickerViewController: PhotoPreviewControllerDataSource {
    
    func numberOfPhotos(in controller: PhotoPreviewController) -> Int {
        guard let album = album else { return 0 }
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        if album.isCameraRoll && !manager.options.captureOptions.mediaOptions.isEmpty {
            return album.assets.count - 1
        }
        #endif
        return album.assets.count
    }
    
    func previewController(_ controller: PhotoPreviewController, assetOfIndex index: Int) -> PreviewData {
        let idx = index + itemOffset
        let indexPath = IndexPath(item: idx, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as? AssetCell
        return (cell?.image, album!.assets[idx])
    }
    
    func previewController(_ controller: PhotoPreviewController, thumbnailViewForIndex index: Int) -> UIView? {
        let idx = index + itemOffset
        let indexPath = IndexPath(item: idx, section: 0)
        return collectionView.cellForItem(at: indexPath) ?? toolBar.leftButton
    }
}

// MARK: - PhotoPreviewControllerDelegate
extension AssetPickerViewController: PhotoPreviewControllerDelegate {
    
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
        let idx = controller.currentIndex + itemOffset
        let indexPath = IndexPath(item: idx, section: 0)
        reloadData(animated: false)
        if !(collectionView.visibleCells.map{ $0.tag }).contains(idx) {
            if idx < collectionView.numberOfItems(inSection: 0) {
                collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            }
        }
    }
}

// MARK: - UICollectionViewDiffable
extension AssetPickerViewController {
    
    enum Section {
        case main
    }
    
    private func reloadData(animated: Bool = true) {
        previewController?.reloadWhenPhotoLibraryDidChange()
        if #available(iOS 14.0, *) {
            let snapshot = initialSnapshot()
            dataSource.apply(snapshot, animatingDifferences: animated)
        } else {
            collectionView.reloadData()
        }
    }
    
    @available(iOS 14.0, *)
    private func initialSnapshot() -> NSDiffableDataSourceSnapshot<Section, Asset> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Asset>()
        snapshot.appendSections([.main])
        snapshot.appendItems(album?.assets ?? [], toSection: .main)
        return snapshot
    }
    
    @available(iOS 14.0, *)
    private func setupDataSource() {
        let cameraCellRegistration = UICollectionView.CellRegistration<CameraCell, Asset> { [weak self] cell, indexPath, asset in
            guard let self = self else { return }
            cell.update(options: self.manager.options)
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = .button
            cell.accessibilityLabel = self.manager.options.theme[string: .pickerTakePhoto]
        }
        
        let cellRegistration = UICollectionView.CellRegistration<AssetCell, Asset> { [weak self] cell, indexPath, asset in
            guard let self = self else { return }
            cell.tag = indexPath.row
            cell.setContent(asset, manager: self.manager)
            cell.selectEvent.delegate(on: self) { (self, _) in
                self.selectItem(indexPath.row)
            }
            cell.backgroundColor = UIColor.white
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = .button
            let accessibilityLabel = self.manager.options.theme[string: asset.mediaType == .video ? .video : .photo]
            cell.accessibilityLabel = "\(accessibilityLabel)\(indexPath.row)"
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Asset>(collectionView: collectionView) { (collectionView, indexPath, asset) -> UICollectionViewCell? in
            if asset.isCamera {
                return collectionView.dequeueConfiguredReusableCell(using: cameraCellRegistration, for: indexPath, item: asset)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: asset)
            }
        }
    }
}
