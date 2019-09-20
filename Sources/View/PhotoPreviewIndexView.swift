//
//  PhotoPreviewSubView.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/20.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

protocol PhotoPreviewIndexViewDelegate: class {
    
    func photoPreviewSubView(_ view: PhotoPreviewIndexView, didSelect idx: Int)
}

final class PhotoPreviewIndexView: UIView {

    public weak var delegate: PhotoPreviewIndexViewDelegate? = nil
    
    public var currentIndex: Int = 0 {
        didSet {
            lastIdx = oldValue
            didSetCurrentIndex()
        }
    }
    
    private var lastIdx: Int = 0
    private var lastAssetList: [Asset] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 64, height: 64)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.backgroundColor = UIColor.color(hex: 0x5C5C5C)
        view.showsHorizontalScrollIndicator = false
        view.registerCell(AssetCell.self)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }
    
    private func didSetCurrentIndex() {
        isHidden = PhotoManager.shared.selectdAsset.isEmpty
        if let idx = PhotoManager.shared.selectdAsset.firstIndex(where: { $0.idx == currentIndex }) {
            let indexPath = IndexPath(item: idx, section: 0)
            collectionView.reloadItems(at: [indexPath])
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        if let idx = PhotoManager.shared.selectdAsset.firstIndex(where: { $0.idx == lastIdx }) {
            collectionView.reloadItems(at: [IndexPath(item: idx, section: 0)])
        }
    }
}

extension PhotoPreviewIndexView {
    
    public func didChangeSelectedAsset() {
        let assetList = PhotoManager.shared.selectdAsset
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
}

extension PhotoPreviewIndexView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotoManager.shared.selectdAsset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(AssetCell.self, for: indexPath)
        let asset = PhotoManager.shared.selectdAsset[indexPath.item]
        cell.backgroundColor = UIColor.white
        cell.setContent(asset, animated: false, isPreview: true)
        cell.selectButton.isHidden = true
        cell.boxCoverView.isHidden = asset.idx != currentIndex
        return cell
    }
    
}

extension PhotoPreviewIndexView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.photoPreviewSubView(self, didSelect: PhotoManager.shared.selectdAsset[indexPath.item].idx)
    }
}
