//
//  AssetPickerViewController.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

let defaultAssetSpacing: CGFloat = 2

final class AssetPickerViewController: UIViewController {
    
    private var album: Album?
    
    private var autoScrollToBottom: Bool = false
    
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
        view.contentInset = UIEdgeInsets(top: defaultAssetSpacing, left: defaultAssetSpacing, bottom: defaultAssetSpacing, right: defaultAssetSpacing)
        view.backgroundColor = UIColor.wechat_dark_background
        view.registerCell(AssetCell.self)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private(set) lazy var toolBar: PhotoPreviewToolBar = {
        let view = PhotoPreviewToolBar(frame: .zero)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
        loadDefaultAlbumIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if autoScrollToBottom {
            collectionView.scrollToBottom(animated: false)
            autoScrollToBottom = false
        }
    }
    
    private func setupNavigation() {
        navigationItem.titleView = titleView
        let cancel = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.leftBarButtonItem = cancel
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalTo(view.snp.edges)
        }
    }
}

extension AssetPickerViewController {
    
    private func loadDefaultAlbumIfNeeded() {
        guard album == nil else { return }
        PhotoManager.shared.fetchCameraRollAlbum(allowPickingVideo: true, allowPickingImage: true, needFetchAssets: true) { [weak self] album in
            guard let self = self else { return }
            self.setAlbum(album)
            self.autoScrollToBottom = true
        }
    }
    
    func setAlbum(_ album: Album) {
        self.album = album
        titleView.setTitle(album.name)
        album.fetchAssets()
        collectionView.reloadData()
        collectionView.scrollToBottom(animated: false)
    }
}

// MARK: - Action

extension AssetPickerViewController {
    
    @objc private func titleViewTapped(_ sender: ArrowButton) {
        let controller = AlbumPickerViewController()
        controller.delegate = self
        let presentationController = MenuDropDownPresentationController(presentedViewController: controller, presenting: self)
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let isFullScreen = UIScreen.main.bounds.height == view.frame.height
        presentationController.navigationHeight = UIScreen.main.bounds.height - (view.frame.height - (navigationController?.navigationBar.bounds.height ?? 0)) + (isFullScreen ? statusBarHeight : 0)
        presentationController.cornerRadius = 8
        presentationController.corners = [.bottomLeft, .bottomRight]
        controller.transitioningDelegate = presentationController
        present(controller, animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
        
        cell.backgroundColor = UIColor.white
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension AssetPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = PhotoPreviewController()
        controller.currentIndex = indexPath.item
        controller.dataSource = self
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AssetPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contentSize = collectionView.bounds.inset(by: collectionView.contentInset).size
        let columnNumber: CGFloat = 4
        let width = floor((contentSize.width-(columnNumber-1)*defaultAssetSpacing)/columnNumber)
        return CGSize(width: width, height: width)
    }
}

extension AssetPickerViewController: AlbumPickerViewControllerDelegate {
    
    func albumPicker(_ picker: AlbumPickerViewController, didSelected album: Album) {
        setAlbum(album)
    }
    
    func albumPickerWillDisappear() {
        titleView.isSelected = false
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
        
    }
}
