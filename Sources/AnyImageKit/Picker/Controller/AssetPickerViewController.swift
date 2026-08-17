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

    enum LGAssetSortOption: Equatable {
        case recentlyAdded
        case capturedDate
    }
    
    weak var delegate: AssetPickerViewControllerDelegate?
    
    internal var albumsPicker: AlbumPickerViewController?
    private(set) var album: Album?
    private(set) var albums = [Album]()
    
    private var preferredCollectionWidth: CGFloat = .zero
    private var autoScrollToLatest: Bool = false
    private var didRegisterPhotoLibraryChangeObserver: Bool = false
    private var containerSize: CGSize = ScreenHelper.mainBounds.size
    private(set) var didAppear: Bool = false
    var lgAssetSortOption: LGAssetSortOption = .recentlyAdded
    
    lazy var stopReloadAlbum: Bool = false
    
    private lazy var titleView: PickerArrowButton = {
        let view = PickerArrowButton(frame: CGRect(x: 0, y: 0, width: 180, height: 32))
        view.addTarget(self, action: #selector(titleViewTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private(set) lazy var section = AssetSection(manager: manager)
    private(set) lazy var collectionView: SKCollectionView = {
        let view = SKCollectionView()
        view.alwaysBounceVertical = true
        view.contentInsetAdjustmentBehavior = .automatic
        view.showsVerticalScrollIndicator = manager.options.scrollIndicator == .none
        if #available(iOS 26.0, *), !manager.options.designRequiresCompatibility {
            view.contentInset = UIEdgeInsets(top: defaultAssetSpacing,
                                             left: defaultAssetSpacing,
                                             bottom: defaultAssetSpacing + toolBarHeight,
                                             right: defaultAssetSpacing)
        } else {
            let hideToolBar = manager.options.selectionTapAction.hideToolBar && manager.options.selectLimit == 1
            let hideFilterBar = !showsMediaTypeFilterBar
            view.contentInset = UIEdgeInsets(top: defaultAssetSpacing + (hideFilterBar ? 0 : 44),
                                             left: defaultAssetSpacing,
                                             bottom: defaultAssetSpacing + (hideToolBar ? 0 : toolBarHeight),
                                             right: defaultAssetSpacing)
        }
        view.backgroundColor = manager.options.theme[color: .background]
        view.manager.prefetching.isEnable = true
        return view
    }()
    
    private(set) lazy var toolBar: PickerToolBar = {
        let view = PickerToolBar(style: .picker)
        view.setEnable(false)
        view.leftButton.addTarget(self, action: #selector(previewButtonTapped), for: .touchUpInside)
        view.originalButton.isSelected = manager.useOriginalImage
        view.originalButton.addTarget(self, action: #selector(originalImageButtonTapped(_:)), for: .touchUpInside)
        view.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        view.permissionLimitedView.limitedButton.addTarget(self, action: #selector(limitedButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private(set) lazy var permissionView: PermissionDeniedView = {
        let view = PermissionDeniedView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    private(set) lazy var indicatorView: PickerIndicatorView = {
        let view = PickerIndicatorView(frame: .zero)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panIndicator(gr:))))
        return view
    }()
    
    private(set) lazy var topDateIndicatorView: PickerDateIndicatorView = {
        let view = PickerDateIndicatorView(frame: .zero)
        view.alpha = 0.0
        return view
    }()
    
    private(set) lazy var filterBar: PickerFilterBar = {
        let view = PickerFilterBar(frame: .zero)
        view.isHidden = !showsMediaTypeFilterBar
        view.selectEvent.delegate(on: self) { (self, _) in
            self.reloadData()
        }
        return view
    }()
    
    private lazy var filterTipsLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.backgroundColor = manager.options.theme[color: .toolBar]
        view.isHidden = true
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    private(set) lazy var lgView: AssetLGView = {
        let view = AssetLGView(frame: .zero)
        return view
    }()
    
    func configureAlbumDisplay() {
        let displaySort: Album.DisplaySort = lgAssetSortOption == .capturedDate ? .capturedDate : .recentlyAdded
        album?.configure(filter: filterBar.selectedType, displaySort: displaySort)
    }
    
    weak var previewController: PhotoPreviewController?
    
    let manager: PickerManager
    
    var showsMediaTypeFilterBar: Bool {
        let mediaTypes = manager.options.selectOptions.mediaTypes
        return !manager.options.mediaTypeFilter.isEmpty
            && mediaTypes.contains(.image)
            && mediaTypes.contains(.video)
    }
    
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
        setupSection()
        checkPermission()
        update(options: manager.options)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lgUpdateToolBarLayout()
        if autoScrollToLatest {
            scrollToEnd()
            autoScrollToLatest = false
        }
        updateIndicator()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle(style: manager.options.theme.style)
    }
    
    private func setupNavigation() {
        if #available(iOS 26.0, *), !manager.options.designRequiresCompatibility {
            lgSetupNavigation()
            return
        }
        navigationItem.titleView = titleView
        let cancel = UIBarButtonItem(title: manager.options.theme[string: .cancel], style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.leftBarButtonItem = cancel
        if showsMediaTypeFilterBar {
            navigationController?.navigationBar.standardAppearance.shadowColor = nil
            navigationController?.navigationBar.standardAppearance.backgroundColor = manager.options.theme[color: .toolBar]
            navigationController?.navigationBar.backgroundColor = manager.options.theme[color: .toolBar]
        }
    }
    
    private func setupView() {
        collectionView.manager.reload(section)
        view.backgroundColor = manager.options.theme[color: .toolBar]
        collectionView.backgroundColor = manager.options.theme[color: .background]
        collectionView.manager.scrollObserver.add(self)
        
        view.addSubview(collectionView)
        view.addSubview(indicatorView)
        view.addSubview(permissionView)
        view.addSubview(topDateIndicatorView)
        view.addSubview(filterTipsLabel)
        
        setupToolBar()
        
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        indicatorView.snp.makeConstraints { make in
            make.top.equalTo(collectionView)
            make.right.equalToSuperview()
            make.width.equalTo(52)
            make.height.equalTo(55)
        }
        permissionView.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            maker.left.right.bottom.equalToSuperview()
        }
        topDateIndicatorView.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
        }
        filterTipsLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupToolBar() {
        if #available(iOS 26.0, *), !manager.options.designRequiresCompatibility {
            lgSetupToolBar()
            return
        }
        view.addSubview(toolBar)
        view.addSubview(filterBar)
        
        toolBar.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-toolBarHeight)
            maker.left.right.bottom.equalToSuperview()
        }
        filterBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
        }
    }
    
    private func setupSection() {
        section.selectedEvent.delegate(on: self) { (self, model) in
            self.selectItem(model.index)
            if self.manager.options.selectLimit == 1 && self.manager.selectedAssets.count == 1 {
                self.doneButtonTapped(self.toolBar.doneButton)
            }
        }
        section.openCaptureEvent.delegate(on: self) { (self, _) in
            self.openCapture()
        }
        section.openEditorEvent.delegate(on: self) { (self, model) in
            self.openEditor(with: model.asset)
        }
        section.openPreviewEvent.delegate(on: self) { (self, model) in
            guard let album = self.album,
                  let displayIndex = album.displayIndex(for: model.asset) else { return }
            let previewIndex = displayIndex - (self.manager.options.orderByDate == .desc && album.hasCamera ? 1 : 0)
            self.openPreview(asset: model.asset, album: album, index: previewIndex)
        }
        section.showAlertEvent.delegate(on: self) { (self, message) in
            self.showAlert(message: message, stringConfig: self.manager.options.theme)
        }
    }
    
    func reloadData(animated: Bool = true, reloadPreview: Bool = true) {
        collectionView.isUserInteractionEnabled = false
        if reloadPreview {
            previewController?.reloadWhenPhotoLibraryDidChange()
        }
        
        UIView.performWithoutAnimation {
            configureAlbumDisplay()
            section.config(album: album, columnCount: manager.options.columnNumber)
            scrollToEnd(animated: false)
        }
        collectionView.isUserInteractionEnabled = true
        
        if manager.options.scrollIndicator != .none && section.itemCount <= 50 {
            indicatorView.isHidden = true
        }
        
        if !filterBar.isHidden {
            filterTipsLabel.isHidden = (album?.count ?? 0) > 0
            switch filterBar.selectedType {
            case .photo:
                filterTipsLabel.text = manager.options.theme[string: .emptyAlbumPhotoTip]
            case .video:
                filterTipsLabel.text = manager.options.theme[string: .emptyAlbumVideoTip]
            default:
                filterTipsLabel.text = ""
            }
        }
    }
}

// MARK: - PickerOptionsConfigurable
extension AssetPickerViewController: PickerOptionsConfigurable {
    
    var childrenConfigurable: [PickerOptionsConfigurable] {
        return preferredChildrenConfigurable + [titleView, lgView]
    }

    func update(options: PickerOptionsInfo) {
        updateChildrenConfigurable(options: options)
        lgUpdateBarButtonAppearance(options: options)
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
    
    func setAlbum(_ album: Album) {
        guard self.album != album else { return }
        self.album = album
        titleView.setTitle(album.title)
        lgView.setAlbumTitle(album.title)
        if manager.options.clearSelectionAfterSwitchingAlbum {
            manager.removeAllSelectedAsset()
        }
        manager.cancelAllFetch()
        toolBarSetEnable(!manager.selectedAssets.isEmpty)
        if !manager.options.clearSelectionAfterSwitchingAlbum {
            manager.selectedAssets.forEach(album.cache)
        }
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        addCameraAssetIfNeeded()
        #endif
    }
    
    private func setAlbums(_ albums: [Album]) {
        self.albums = albums.filter { $0.count > 0 }
        if let albumsPicker = albumsPicker {
            albumsPicker.albums = albums
            albumsPicker.reloadData()
        }
        lgSetupAlbumMenu()
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
    
    func reloadAlbum(_ album: Album) {
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
            if !album.contains(identifier: asset.identifier) {
                manager.removeSelectedAsset(asset)
            }
        }
        for asset in manager.selectedAssets {
            album.cache(asset)
        }
        toolBarSetEnable(!manager.selectedAssets.isEmpty)
        
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
        if #available(iOS 26.0, *), !manager.options.designRequiresCompatibility {
            lgView.limitedButton.isHidden = false
            return
        }
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
        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell),
               let asset = section.asset(at: indexPath.item),
               let cell = cell as? AssetCell {
                cell.updateState(asset, manager: manager, animated: animatedItem == indexPath.item)
            }
        }
    }
    
    func displayIndex(for asset: Asset) -> Int? {
        album?.displayIndex(for: asset)
    }
    
    private func preselectAssets() {
        let preselectAssets = manager.options.preselectAssets
        if preselectAssets.isEmpty { return }
        for identifier in preselectAssets {
            if let index = album?.displayIndex(forIdentifier: identifier),
               let asset = album?.asset(at: index) {
                manager.addSelectedAsset(asset)
            }
        }
        toolBarSetEnable(!manager.selectedAssets.isEmpty)
    }
    
    func scrollToEnd(animated: Bool = false) {
        if manager.options.orderByDate == .asc {
            collectionView.scrollToLast(at: .bottom, animated: animated)
        } else {
            collectionView.scrollToFirst(at: .top, animated: animated)
        }
    }
    
    func selectItem(_ idx: Int) {
        guard let asset = section.asset(at: idx) else { return }
        
        if !asset.isSelected {
            let result = manager.addSelectedAsset(asset)
            if !result.success && !result.message.isEmpty {
                showAlert(message: result.message, stringConfig: manager.options.theme)
            }
        } else {
            manager.removeSelectedAsset(asset)
        }
        updateVisibleCellState(idx)
        
        toolBarSetEnable(!manager.selectedAssets.isEmpty)
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
            guard let idx = self.displayIndex(for: asset) else { return }
            guard let cell = self.collectionView.cellForItem(at: IndexPath(row: idx, section: 0)) as? AssetCell else { return }
            cell.selectEvent.call()
        }
    }
}



// MARK: - PHPhotoLibraryChangeObserver
extension AssetPickerViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let album = album, let changeDetails = changeInstance.changeDetails(for: album.fetchResult) else { return }
        
        if #available(iOS 14.0, *), Permission.photos.status == .limited {
            if album.isCameraRoll {
                reloadAlbum(album)
            } else {
                DispatchQueue.main.async {
                    if !self.manager.options.clearSelectionAfterSwitchingAlbum,
                       let smartAlbum = self.albums.first(where: { $0.isCameraRoll }) {
                        self.setAlbum(smartAlbum)
                        self.reloadAlbum(smartAlbum)
                        self.updateAlbum(smartAlbum)
                    } else {
                        self.reloadAlbum(album)
                    }
                }
            }
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

//
//// MARK: - UICollectionViewDelegateFlowLayout
//extension AssetPickerViewController: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let maxSize = CGRect(origin: .zero, size: containerSize).inset(by: collectionView.contentInset).size
//        let columnNumber: CGFloat
//        if UIDevice.current.userInterfaceIdiom == .phone || !manager.options.autoCalculateColumnNumber {
//            columnNumber = CGFloat(manager.options.columnNumber)
//        } else {
//            let minWidth: CGFloat = 135
//            columnNumber = max(CGFloat(Int(maxSize.width / minWidth)), 3)
//        }
//        let width = max(0, floor((maxSize.width-(columnNumber-1)*defaultAssetSpacing)/columnNumber))
//        return CGSize(width: width, height: width)
//    }
//}

// MARK: - UIScrollViewDelegate
extension AssetPickerViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleIndicatorWhenScrollViewDidScroll(scrollView)
        updateLimitedButton()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        showIndicator(true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            showIndicator(false)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !indicatorView.inPan {
            showIndicator(false)
        }
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

// MARK: - PhotoPreviewControllerDelegate
extension AssetPickerViewController: PhotoPreviewControllerDelegate {
    
    func previewController(_ controller: PhotoPreviewController, didSelected index: Int) {
        updateVisibleCellState()
        toolBarSetEnable(true)
    }
    
    func previewController(_ controller: PhotoPreviewController, didDeselected index: Int) {
        updateVisibleCellState()
        toolBarSetEnable(!manager.selectedAssets.isEmpty)
    }

    func previewController(_ controller: PhotoPreviewController, didFinishEditing index: Int) {
        guard let asset = controller.asset(at: index) else { return }
        guard let displayIndex = displayIndex(for: asset),
              let cell = section.cellForItem(at: displayIndex) as? AssetCell else { return }
        cell.config(.init(asset: asset, manager: manager))
    }
    
    func previewController(_ controller: PhotoPreviewController, useOriginalImage: Bool) {
        toolBar.originalButton.isSelected = useOriginalImage
    }
    
    func previewControllerDidClickDone(_ controller: PhotoPreviewController) {
        stopReloadAlbum = true
        delegate?.assetPickerDidFinishPicking(self)
    }
    
    func preview(_ controller: PhotoPreviewController, didChangeIndex index: Int) {
        switch controller.sourceType {
        case .album:
            guard let asset = controller.asset(at: index),
                  let idx = displayIndex(for: asset) else { return }
            let indexPath = IndexPath(item: idx, section: 0)
            if !collectionView.indexPathsForVisibleItems.contains(indexPath),
               idx < collectionView.numberOfItems(inSection: 0) {
                collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            }
        case .selectedAssets:
            break
        }
    }
    
    
}
