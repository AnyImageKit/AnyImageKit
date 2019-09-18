//
//  AssetPickerViewController.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

final class AssetPickerViewController: UIViewController {
    
    private var album: Album?
    
    private lazy var titleView: ArrowButton = {
        let view = ArrowButton(frame: CGRect(x: 0, y: 0, width: 180, height: 32))
        return view
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.registerCell(AssetCell.self)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
        loadDefaultAlbumIfNeeded()
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
        }
    }
    
    func setAlbum(_ album: Album) {
        self.album = album
        titleView.setTitle(album.name)
        collectionView.reloadData()
    }
}

// MARK: - Action

extension AssetPickerViewController {
    
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
            cell.set(content: asset)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension AssetPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
