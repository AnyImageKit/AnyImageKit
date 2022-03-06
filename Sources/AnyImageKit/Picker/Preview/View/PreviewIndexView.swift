//
//  PreviewIndexView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/20.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

protocol PreviewIndexViewDelegate: AnyObject {
    
    func pickerPreviewIndexView(_ view: PreviewIndexView, didSelect idx: Int)
}

final class PreviewIndexView: UIView {
    
    weak var delegate: PreviewIndexViewDelegate?
    
    var assetIndex: Int = 0 {
        didSet {
            lastAssetIndex = oldValue
            didSetAssetIndex()
        }
    }
    
    private var isFirst = true
    private var lastAssetIndex: Int?
    private var lastAssetList: [Asset<PHAsset>] = []
    
    private var options: PickerOptionsInfo?
    
    private lazy var collectionView: UICollectionView = makeCollectionView()
    
    private let photoLibrary: PhotoLibraryAssetCollection
    
    init(photoLibrary: PhotoLibraryAssetCollection) {
        self.photoLibrary = photoLibrary
        self.lastAssetList = photoLibrary.selectedItems
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectItemAtFirstTime()
    }
}

// MARK: - PickerOptionsConfigurable
extension PreviewIndexView: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        collectionView.backgroundColor = options.theme[color: .toolBar].withAlphaComponent(0.95)
        updateChildrenConfigurable(options: options)
        self.options = options
    }
}

extension PreviewIndexView {
    
    func didChangeSelectedAsset() {
        let assetList = photoLibrary.selectedItems
        self.isHidden = assetList.isEmpty
        if lastAssetList.count < assetList.count {
            collectionView.insertItems(at: [IndexPath(item: assetList.count-1, section: 0)])
            collectionView.scrollToLast(at: .right, animated: true)
        } else if lastAssetList.count > assetList.count {
            for (idx, asset) in lastAssetList.enumerated() {
                if !assetList.contains(asset) {
                    collectionView.deleteItems(at: [IndexPath(item: idx, section: 0)])
                    break
                }
            }
        }
        lastAssetList = assetList
    }
    
    private func didSetAssetIndex() {
        isHidden = photoLibrary.selectedItems.isEmpty
        if let asset = photoLibrary.loadAsset(for: assetIndex), let index = photoLibrary.selectedItems.firstIndex(of: asset) {
            let indexPath = IndexPath(item: index, section: 0)
            collectionView.reloadItems(at: [indexPath])
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        if let lastIndex = lastAssetIndex, let asset = photoLibrary.loadAsset(for: lastIndex), let index = photoLibrary.selectedItems.firstIndex(of: asset) {
            let indexPath = IndexPath(item: index, section: 0)
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func selectItemAtFirstTime() {
        if !isFirst { return }
        isFirst = false
        if let asset = photoLibrary.loadAsset(for: assetIndex), let index = photoLibrary.selectedItems.firstIndex(of: asset) {
            let indexPath = IndexPath(item: index, section: 0)
            collectionView.reloadItems(at: [indexPath])
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
}

// MARK: - UI Setup
extension PreviewIndexView {
    
    private func setupView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
    
    private func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 64, height: 64)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.showsHorizontalScrollIndicator = false
        view.registerCell(PhotoAssetCell.self)
        view.dataSource = self
        view.delegate = self
        return view
    }
}

// MARK: - UICollectionViewDataSource
extension PreviewIndexView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoLibrary.selectedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(PhotoAssetCell.self, for: indexPath)
        let asset = photoLibrary.selectedItems[indexPath.item]
        cell.setContent(asset: asset, animated: false, isPreview: true)
        if let options = options {
            cell.update(options: options)
        }
        cell.selectButton.isHidden = true
        if let index = photoLibrary.loadAssetIndex(for: asset) {
            cell.borderView.isHidden = index != assetIndex
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PreviewIndexView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photoLibrary.selectedItems[indexPath.item]
        if let index = photoLibrary.loadAssetIndex(for: asset) {
            delegate?.pickerPreviewIndexView(self, didSelect: index)
        }
    }
}
