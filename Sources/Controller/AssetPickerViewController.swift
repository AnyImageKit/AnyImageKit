//
//  AssetPickerViewController.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

private let defaultAssetSpacing: CGFloat = 2
private let toolBarHeight: CGFloat = 56

protocol AssetPickerViewControllerDelegate: class {
    
    func assetPickerControllerDidClickDone(_ controller: AssetPickerViewController)
}

final class AssetPickerViewController: UIViewController {
    
    public weak var delegate: AssetPickerViewControllerDelegate?
    
    private var albumsPicker: AlbumPickerViewController?
    private var album: Album?
    private var albums = [Album]()
    
    private var autoScrollToLatest: Bool = false
    
    private lazy var titleView: ArrowButton = {
        let view = ArrowButton(frame: CGRect(x: 0, y: 0, width: 180, height: 32))
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
        view.backgroundColor = PhotoManager.shared.config.theme.backgroundColor
        view.registerCell(AssetCell.self)
        view.registerCell(TakePhotoCell.self)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private(set) lazy var toolBar: PhotoToolBar = {
        let view = PhotoToolBar(style: .picker)
        view.setEnable(false)
        view.originalButton.isHidden = !PhotoManager.shared.config.allowUseOriginalImage
        view.originalButton.isSelected = PhotoManager.shared.useOriginalImage
        view.leftButton.addTarget(self, action: #selector(previewButtonTapped(_:)), for: .touchUpInside)
        view.originalButton.addTarget(self, action: #selector(originalImageButtonTapped(_:)), for: .touchUpInside)
        view.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private lazy var permissionView: PermissionDeniedView = {
        let view = PermissionDeniedView()
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
        check()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if autoScrollToLatest {
            if PhotoManager.shared.config.orderByDate == .asc {
                collectionView.scrollToLast(at: .bottom, animated: false)
            } else {
                collectionView.scrollToFirst(at: .top, animated: false)
            }
            autoScrollToLatest = false
        }
    }
    
    private func setupNavigation() {
        navigationItem.titleView = titleView
        let cancel = UIBarButtonItem(title: BundleHelper.localizedString(key: "Cancel"), style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
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
        PhotoManager.shared.fetchCameraRollAlbum { [weak self] album in
            guard let self = self else { return }
            self.setAlbum(album)
            self.autoScrollToLatest = true
        }
    }
    
    private func preLoadAlbums() {
        PhotoManager.shared.fetchAllAlbums { [weak self] albums in
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
        if PhotoManager.shared.config.orderByDate == .asc {
            collectionView.scrollToLast(at: .bottom, animated: false)
        } else {
            collectionView.scrollToFirst(at: .top, animated: false)
        }
        PhotoManager.shared.removeAllSelectedAsset()
        PhotoManager.shared.cancelAllFetch()
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
                cell.updateState(album.assets[indexPath.item], animated: animatedItem == indexPath.item)
            }
        }
    }
    
    /// 弹出 UIImagePickerController
    private func showUIImagePicker() {
        let manager = PhotoManager.shared
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = false
        controller.sourceType = .camera
        controller.videoMaximumDuration = manager.config.videoMaximumDuration
        var mediaTypes: [String] = []
        if manager.config.allowTakePhoto {
            mediaTypes.append(kUTTypeImage as String)
        }
        if manager.config.allowTakeVideo {
            mediaTypes.append(kUTTypeMovie as String)
        }
        controller.mediaTypes = mediaTypes
        present(controller, animated: true, completion: nil)
    }
    
    /// 添加拍照 Item
    private func addCameraAsset() {
        guard let album = album, album.isCameraRoll else { return }
        let manager = PhotoManager.shared
        let sortType = manager.config.orderByDate
        if manager.config.allowTakePhoto || manager.config.allowTakeVideo {
            switch sortType {
            case .asc:
                album.addAsset(Asset(idx: -1, asset: PHAsset()), atLast: true)
            case .desc:
                album.insertAsset(Asset(idx: -1, asset: PHAsset()), at: 0)
            }
        }
    }
    
    /// 拍照结束后，插入 PHAsset
    private func addPHAsset(_ phAsset: PHAsset) {
        guard let album = album else { return }
        let sortType = PhotoManager.shared.config.orderByDate
        switch sortType {
        case .asc:
            album.addAsset(Asset(idx: album.assets.count, asset: phAsset), atLast: false)
            collectionView.insertItems(at: [IndexPath(item: album.assets.count-2, section: 0)])
        case .desc:
            album.insertAsset(Asset(idx: 0, asset: phAsset), at: 1)
            collectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
        }
    }
}

// MARK: - Action
extension AssetPickerViewController {
    
    @objc private func titleViewTapped(_ sender: ArrowButton) {
        let controller = AlbumPickerViewController()
        controller.album = album
        controller.albums = albums
        controller.delegate = self
        let presentationController = MenuDropDownPresentationController(presentedViewController: controller, presenting: self)
        let statusBarHeight = StatusBarHelper.height
        let isFullScreen = UIScreen.main.bounds.height == view.frame.height
        presentationController.navigationHeight = UIScreen.main.bounds.height - (view.frame.height - (navigationController?.navigationBar.bounds.height ?? 0)) + (isFullScreen ? statusBarHeight : 0)
        presentationController.cornerRadius = 8
        presentationController.corners = [.bottomLeft, .bottomRight]
        controller.transitioningDelegate = presentationController
        self.albumsPicker = controller
        present(controller, animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        PhotoManager.shared.removeAllSelectedAsset()
    }
    
    @objc private func selectButtonTapped(_ sender: NumberCircleButton) {
        guard let album = album else { return }
        guard let cell = sender.superview as? AssetCell else { return }
        guard let idx = collectionView.indexPath(for: cell)?.item else { return }
        let asset = album.assets[idx]
        if !asset.isSelected && PhotoManager.shared.isMaxCount {
            let message = String(format: BundleHelper.localizedString(key: "Select a maximum of %zd photos"), PhotoManager.shared.config.countLimit)
            let alert = UIAlertController(title: BundleHelper.localizedString(key: "Alert"), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: BundleHelper.localizedString(key: "OK"), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        asset.isSelected = !sender.isSelected
        if asset.isSelected {
            PhotoManager.shared.addSelectedAsset(asset)
            updateVisibleCellState(idx)
        } else {
            PhotoManager.shared.removeSelectedAsset(asset)
            updateVisibleCellState(idx)
        }
        toolBar.setEnable(!PhotoManager.shared.selectdAssets.isEmpty)
    }
    
    @objc private func previewButtonTapped(_ sender: UIButton) {
        guard let asset = PhotoManager.shared.selectdAssets.first else { return }
        let controller = PhotoPreviewController()
        controller.currentIndex = asset.idx
        controller.dataSource = self
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    @objc private func originalImageButtonTapped(_ sender: OriginalButton) {
        PhotoManager.shared.useOriginalImage = sender.isSelected
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        delegate?.assetPickerControllerDidClickDone(self)
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
            let cell = collectionView.dequeueReusableCell(TakePhotoCell.self, for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(AssetCell.self, for: indexPath)
        cell.setContent(asset)
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
        
        if !album.assets[indexPath.item].isSelected && PhotoManager.shared.isMaxCount { return }
        let controller = PhotoPreviewController()
        controller.currentIndex = indexPath.item
        controller.dataSource = self
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let asset = album?.assets[indexPath.item], !asset.isCamera else { return }
        if let cell = cell as? AssetCell {
            cell.updateState(asset, animated: false)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AssetPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contentSize = collectionView.bounds.inset(by: collectionView.contentInset).size
        let columnNumber = CGFloat(PhotoManager.shared.config.columnNumber)
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
        return album!.assets.count
    }
    
    func previewController(_ controller: PhotoPreviewController, assetOfIndex index: Int) -> PreviewData {
        let indexPath = IndexPath(item: index, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as? AssetCell
        return (cell?.image, album!.assets[index])
    }
    
    func previewController(_ controller: PhotoPreviewController, thumbnailViewForIndex index: Int) -> UIView? {
        let indexPath = IndexPath(item: index, section: 0)
        return collectionView.cellForItem(at: indexPath)
    }
}

// MARK: - PhotoPreviewControllerDelegate
extension AssetPickerViewController: PhotoPreviewControllerDelegate {
    
    func previewController(_ controller: PhotoPreviewController, didSelected index: Int) {
        updateVisibleCellState()
    }
    
    func previewController(_ controller: PhotoPreviewController, didDeselected index: Int) {
        updateVisibleCellState()
    }
    
    func previewController(_ controller: PhotoPreviewController, useOriginalImage: Bool) {
        toolBar.originalButton.isSelected = useOriginalImage
    }
    
    func previewControllerDidClickDone(_ controller: PhotoPreviewController) {
        guard let album = album else { return }
        if PhotoManager.shared.selectdAssets.isEmpty {
            PhotoManager.shared.addSelectedAsset(album.assets[controller.currentIndex])
        }
        delegate?.assetPickerControllerDidClickDone(self)
    }
}

extension AssetPickerViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let mediaType = info[.mediaType] as? String else { return }
        let mediaTypeImage = kUTTypeImage as String
        let mediaTypeMovie = kUTTypeMovie as String
        // TODO: HUD
        switch mediaType {
        case mediaTypeImage:
            guard let image = info[.originalImage] as? UIImage else { return }
            guard let meta = info[.mediaMetadata] as? [String:Any] else { return }
            PhotoManager.shared.savePhoto(image, meta: meta) { [weak self] (result) in
                switch result {
                case .success(let asset):
                    self?.addPHAsset(asset)
                case .failure(let error):
                    _print(error.localizedDescription)
                }
            }
        case mediaTypeMovie:
            guard let videoUrl = info[.mediaURL] as? URL else { return }
            PhotoManager.shared.saveVideo(for: videoUrl) { [weak self] (result) in
                switch result {
                case .success(let asset):
                    self?.addPHAsset(asset)
                case .failure(let error):
                    _print(error.localizedDescription)
                }
            }
        default:
            break
        }
    }
}

extension AssetPickerViewController: UINavigationControllerDelegate {
    
}
