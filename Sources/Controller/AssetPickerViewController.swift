//
//  AssetPickerViewController.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import Photos

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
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private(set) lazy var toolBar: PhotoToolBar = {
        let view = PhotoToolBar(style: .picker)
        view.setEnable(false)
        view.originalButton.isHidden = !PhotoManager.shared.config.allowUseOriginalPhoto
        view.originalButton.isSelected = PhotoManager.shared.isOriginalPhoto
        view.leftButton.addTarget(self, action: #selector(previewButtonTapped(_:)), for: .touchUpInside)
        view.originalButton.addTarget(self, action: #selector(originalPhotoButtonTapped(_:)), for: .touchUpInside)
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
        permissionView.snp.makeConstraints { (maker) in
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
    
    func setAlbum(_ album: Album) {
        guard self.album != album else { return }
        self.album = album
        titleView.setTitle(album.name)
        album.fetchAssets()
        collectionView.reloadData()
        if PhotoManager.shared.config.orderByDate == .asc {
            collectionView.scrollToLast(at: .bottom, animated: false)
        } else {
            collectionView.scrollToFirst(at: .top, animated: false)
        }
        PhotoManager.shared.removeAllSelectedAsset()
    }
    
    private func setAlbums(_ albums: [Album]) {
        self.albums = albums
        if let albumsPicker = albumsPicker {
            print(albumsPicker.isBeingPresented)
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
    
    @objc private func selectButtonTapped(_ sender: UIButton) {
        guard let album = album else { return }
        let asset = album.assets[sender.tag]
        if !asset.isSelected && PhotoManager.shared.isMaxCount {
            let message = String(format: BundleHelper.localizedString(key: "Select a maximum of %zd photos"), PhotoManager.shared.config.maxCount)
            let alert = UIAlertController(title: BundleHelper.localizedString(key: "Alert"), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: BundleHelper.localizedString(key: "OK"), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        asset.isSelected = !sender.isSelected
        if asset.isSelected {
            PhotoManager.shared.addSelectedAsset(asset)
            updateVisibleCellState(sender.tag)
        } else {
            PhotoManager.shared.removeSelectedAsset(asset)
            updateVisibleCellState(sender.tag)
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
    
    @objc private func originalPhotoButtonTapped(_ sender: OriginalButton) {
        PhotoManager.shared.isOriginalPhoto = sender.isSelected
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
        let cell = collectionView.dequeueReusableCell(AssetCell.self, for: indexPath)
        if let asset = album?.assets[indexPath.item] {
            cell.setContent(asset)
        }
        cell.selectButton.tag = indexPath.item
        cell.selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        cell.backgroundColor = UIColor.white
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension AssetPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let album = album else { return }
        if !album.assets[indexPath.item].isSelected && PhotoManager.shared.isMaxCount { return }
        
        let controller = PhotoPreviewController()
        controller.currentIndex = indexPath.item
        controller.dataSource = self
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let asset = album?.assets[indexPath.item] else { return }
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
    
    func previewController(_ controller: PhotoPreviewController, useOriginalPhoto: Bool) {
        toolBar.originalButton.isSelected = useOriginalPhoto
    }
    
    func previewControllerDidClickDone(_ controller: PhotoPreviewController) {
        guard let album = album else { return }
        if PhotoManager.shared.selectdAssets.isEmpty {
            PhotoManager.shared.addSelectedAsset(album.assets[controller.currentIndex])
        }
        delegate?.assetPickerControllerDidClickDone(self)
    }
}
