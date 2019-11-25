//
//  AssetPickerViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

private let defaultAssetSpacing: CGFloat = 2
private let toolBarHeight: CGFloat = 56

protocol AssetPickerViewControllerDelegate: class {
    
    func assetPickerDidCancel(_ picker: AssetPickerViewController)
    func assetPickerDidFinishPicking(_ picker: AssetPickerViewController)
}

final class AssetPickerViewController: UIViewController {
    
    weak var delegate: AssetPickerViewControllerDelegate?
    
    private var albumsPicker: AlbumPickerViewController?
    private var album: Album?
    private var albums = [Album]()
    
    private var preferredCollectionWidth: CGFloat = .zero
    private var autoScrollToLatest: Bool = false
    
    private lazy var titleView: PickerArrowButton = {
        let view = PickerArrowButton(frame: CGRect(x: 0, y: 0, width: 180, height: 32), config: manager.config)
        view.addTarget(self, action: #selector(titleViewTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = defaultAssetSpacing
        layout.minimumInteritemSpacing = defaultAssetSpacing
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = UIEdgeInsets(top: defaultAssetSpacing,
                                         left: defaultAssetSpacing,
                                         bottom: toolBarHeight + defaultAssetSpacing,
                                         right: defaultAssetSpacing)
        view.backgroundColor = manager.config.theme.backgroundColor
        view.registerCell(AssetCell.self)
        view.registerCell(CameraCell.self)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private(set) lazy var toolBar: PickerToolBar = {
        let view = PickerToolBar(style: .picker, config: manager.config)
        view.setEnable(false)
        view.originalButton.isHidden = !manager.config.allowUseOriginalImage
        view.originalButton.isSelected = manager.useOriginalImage
        view.leftButton.addTarget(self, action: #selector(previewButtonTapped(_:)), for: .touchUpInside)
        view.originalButton.addTarget(self, action: #selector(originalImageButtonTapped(_:)), for: .touchUpInside)
        view.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private lazy var permissionView: PermissionDeniedView = {
        let view = PermissionDeniedView(frame: .zero, config: manager.config)
        view.isHidden = true
        return view
    }()
    
    private lazy var itemOffset: Int = {
        switch manager.config.orderByDate {
        case .asc:
            return 0
        case .desc:
            return 1
        }
    }()
    
    let manager: PickerManager
    
    init(manager: PickerManager) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotifications()
        setupNavigation()
        setupView()
        check()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if autoScrollToLatest {
            if manager.config.orderByDate == .asc {
                collectionView.scrollToLast(at: .bottom, animated: false)
            } else {
                collectionView.scrollToFirst(at: .top, animated: false)
            }
            autoScrollToLatest = false
        }
    }
    
    private func setupNavigation() {
        navigationItem.titleView = titleView
        let cancel = UIBarButtonItem(title: BundleHelper.pickerLocalizedString(key: "Cancel"), style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
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
            if #available(iOS 11, *) {
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
}

// MARK: - Private function
extension AssetPickerViewController {
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(containerSizeDidChange(_:)), name: .containerSizeDidChange, object: nil)
    }
    
    private func check() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] (_) in
                DispatchQueue.main.async {
                    self?.check()
                }
            }
        case .authorized:
            self.loadDefaultAlbumIfNeeded()
            self.preLoadAlbums()
        default:
            permissionView.isHidden = false
        }
    }
    
    private func loadDefaultAlbumIfNeeded() {
        guard album == nil else { return }
        manager.fetchCameraRollAlbum { [weak self] album in
            guard let self = self else { return }
            self.setAlbum(album)
            self.autoScrollToLatest = true
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
        titleView.setTitle(album.name)
        addCameraAsset()
        collectionView.reloadData()
        if manager.config.orderByDate == .asc {
            collectionView.scrollToLast(at: .bottom, animated: false)
        } else {
            collectionView.scrollToFirst(at: .top, animated: false)
        }
        manager.removeAllSelectedAsset()
        manager.cancelAllFetch()
    }
    
    private func setAlbums(_ albums: [Album]) {
        self.albums = albums.filter{ !$0.assets.isEmpty }
        if let albumsPicker = albumsPicker {
            albumsPicker.albums = albums
            albumsPicker.reloadData()
        }
    }
    
    private func updateVisibleCellState(_ animatedItem: Int = -1) {
        guard let album = album else { return }
        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell), let cell = cell as? AssetCell {
                cell.updateState(album.assets[indexPath.item], manager: manager, animated: animatedItem == indexPath.item)
            }
        }
    }
    
    /// 弹出 UIImagePickerController
    private func showUIImagePicker() {
        #if !targetEnvironment(simulator)
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = false
        controller.sourceType = .camera
        controller.videoMaximumDuration = manager.captureConfig.videoMaximumDuration
        var mediaTypes: [String] = []
        if manager.captureConfig.captureMediaOptions.contains(.photo) {
            mediaTypes.append(kUTTypeImage as String)
        }
        if manager.captureConfig.captureMediaOptions.contains(.video) {
            mediaTypes.append(kUTTypeMovie as String)
        }
        controller.mediaTypes = mediaTypes
        present(controller, animated: true, completion: nil)
        #else
        let alert = UIAlertController(title: "Error", message: "Camera is unavailable on simulator", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        #endif
    }
    
    /// 添加拍照 Item
    private func addCameraAsset() {
        guard let album = album, album.isCameraRoll else { return }
        let config = manager.config
        let sortType = config.orderByDate
        if !manager.captureConfig.captureMediaOptions.isEmpty {
            switch sortType {
            case .asc:
                album.addAsset(Asset(idx: -1, asset: PHAsset(), selectOptions: config.selectOptions), atLast: true)
            case .desc:
                album.insertAsset(Asset(idx: -1, asset: PHAsset(), selectOptions: config.selectOptions), at: 0, sort: config.orderByDate)
            }
        }
    }
    
    /// 拍照结束后，插入 PHAsset
    private func addPHAsset(_ phAsset: PHAsset) {
        guard let album = album else { return }
        let sortType = manager.config.orderByDate
        let addSuccess: Bool
        switch sortType {
        case .asc:
            let asset = Asset(idx: album.assets.count-1, asset: phAsset, selectOptions: manager.config.selectOptions)
            album.addAsset(asset, atLast: false)
            addSuccess = manager.addSelectedAsset(asset)
            collectionView.insertItems(at: [IndexPath(item: album.assets.count-2, section: 0)])
        case .desc:
            let asset = Asset(idx: 0, asset: phAsset, selectOptions: manager.config.selectOptions)
            album.insertAsset(asset, at: 1, sort: manager.config.orderByDate)
            addSuccess = manager.addSelectedAsset(asset)
            collectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
        }
        updateVisibleCellState()
        toolBar.setEnable(true)
        if addSuccess {
            finishSelectedIfNeeded()
        }
    }
    
    /// 拍照结束后，如果 limit=1 直接返回
    private func finishSelectedIfNeeded() {
        if manager.config.selectLimit == 1 {
            delegate?.assetPickerDidFinishPicking(self)
        }
    }
}

// MARK: - Target
extension AssetPickerViewController {
    
    @objc private func containerSizeDidChange(_ sender: Notification) {
        collectionView.reloadData()
    }
    
    @objc private func titleViewTapped(_ sender: PickerArrowButton) {
        let controller = AlbumPickerViewController(manager: manager)
        controller.album = album
        controller.albums = albums
        controller.delegate = self
        let presentationController = MenuDropDownPresentationController(presentedViewController: controller, presenting: self)
        let isFullScreen = ScreenHelper.mainBounds.height == view.frame.height
        presentationController.isFullScreen = isFullScreen
        presentationController.cornerRadius = 8
        presentationController.corners = [.bottomLeft, .bottomRight]
        controller.transitioningDelegate = presentationController
        self.albumsPicker = controller
        present(controller, animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.assetPickerDidCancel(self)
    }
    
    @objc private func selectButtonTapped(_ sender: NumberCircleButton) {
        guard let album = album else { return }
        guard let cell = sender.superview as? AssetCell else { return }
        guard let idx = collectionView.indexPath(for: cell)?.item else { return }
        let asset = album.assets[idx]
        if !asset.isSelected && manager.isUpToLimit {
            let message = String(format: BundleHelper.pickerLocalizedString(key: "Select a maximum of %zd photos"), manager.config.selectLimit)
            let alert = UIAlertController(title: BundleHelper.pickerLocalizedString(key: "Alert"), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: BundleHelper.pickerLocalizedString(key: "OK"), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        asset.isSelected = !sender.isSelected
        if asset.isSelected {
            manager.addSelectedAsset(asset)
            updateVisibleCellState(idx)
        } else {
            manager.removeSelectedAsset(asset)
            updateVisibleCellState(idx)
        }
        toolBar.setEnable(!manager.selectedAssets.isEmpty)
    }
    
    @objc private func previewButtonTapped(_ sender: UIButton) {
        guard let asset = manager.selectedAssets.first else { return }
        let controller = PhotoPreviewController(manager: manager)
        controller.currentIndex = asset.idx
        controller.dataSource = self
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    @objc private func originalImageButtonTapped(_ sender: OriginalButton) {
        manager.useOriginalImage = sender.isSelected
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        delegate?.assetPickerDidFinishPicking(self)
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
        if asset.isCamera {
            let cell = collectionView.dequeueReusableCell(CameraCell.self, for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(AssetCell.self, for: indexPath)
        cell.setContent(asset, manager: manager)
        cell.selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        cell.backgroundColor = UIColor.white
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension AssetPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let album = album else { return }
        if album.assets[indexPath.item].isCamera { // 点击拍照 Item
            showUIImagePicker()
            return
        }
        
        if !album.assets[indexPath.item].isSelected && manager.isUpToLimit { return }
        let controller = PhotoPreviewController(manager: manager)
        controller.currentIndex = indexPath.item - itemOffset
        controller.dataSource = self
        controller.delegate = self
        present(controller, animated: true, completion: nil)
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
        let contentSize = collectionView.bounds.inset(by: collectionView.contentInset).size
        let columnNumber = CGFloat(manager.config.columnNumber)
        let width = floor((contentSize.width-(columnNumber-1)*defaultAssetSpacing)/columnNumber)
        return CGSize(width: width, height: width)
    }
}

// MARK: - AlbumPickerViewControllerDelegate
extension AssetPickerViewController: AlbumPickerViewControllerDelegate {
    
    func albumPicker(_ picker: AlbumPickerViewController, didSelected album: Album) {
        setAlbum(album)
    }
    
    func albumPickerWillDisappear() {
        titleView.isSelected = false
        albumsPicker = nil
    }
}

// MARK: - PhotoPreviewControllerDataSource
extension AssetPickerViewController: PhotoPreviewControllerDataSource {
    
    func numberOfPhotos(in controller: PhotoPreviewController) -> Int {
        guard let album = album else { return 0 }
        if album.isCameraRoll && !manager.captureConfig.captureMediaOptions.isEmpty {
            return album.assets.count - 1
        }
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
        return collectionView.cellForItem(at: indexPath)
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
        guard let album = album else { return }
        if manager.selectedAssets.isEmpty {
            let idx = controller.currentIndex + itemOffset
            manager.addSelectedAsset(album.assets[idx])
        }
        delegate?.assetPickerDidFinishPicking(self)
    }
    
    func previewControllerWillDisappear(_ controller: PhotoPreviewController) {
        let idx = controller.currentIndex + itemOffset
        let indexPath = IndexPath(item: idx, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - UIImagePickerControllerDelegate
extension AssetPickerViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let mediaType = info[.mediaType] as? String else { return }
        let mediaTypeImage = kUTTypeImage as String
        let mediaTypeMovie = kUTTypeMovie as String
        showWaitHUD()
        switch mediaType {
        case mediaTypeImage:
            guard let image = info[.originalImage] as? UIImage else { return }
            guard let metadata = info[.mediaMetadata] as? [String:Any] else { return }
            manager.savePhoto(image, metadata: metadata) { [weak self] (result) in
                switch result {
                case .success(let asset):
                    self?.addPHAsset(asset)
                case .failure(let error):
                    _print(error.localizedDescription)
                }
                hideHUD()
            }
        case mediaTypeMovie:
            guard let videoUrl = info[.mediaURL] as? URL else { return }
            manager.saveVideo(at: videoUrl) { [weak self] (result) in
                switch result {
                case .success(let asset):
                    self?.addPHAsset(asset)
                case .failure(let error):
                    _print(error.localizedDescription)
                }
                hideHUD()
            }
        default:
            break
        }
    }
}

extension AssetPickerViewController: UINavigationControllerDelegate {
    
}
