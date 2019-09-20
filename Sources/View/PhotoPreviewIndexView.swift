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
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = defaultAssetSpacing
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        view.backgroundColor = UIColor.color(hex: 0x5C5C5C)
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
            collectionView.reloadItems(at: [IndexPath(item: idx, section: 0)])
        }
        if let idx = PhotoManager.shared.selectdAsset.firstIndex(where: { $0.idx == lastIdx }) {
            collectionView.reloadItems(at: [IndexPath(item: idx, section: 0)])
        }
    }
}

extension PhotoPreviewIndexView {
    
    public func didChangeSelectedAsset() {
        self.isHidden = PhotoManager.shared.selectdAsset.isEmpty
        collectionView.reloadSections(IndexSet(integer: 0))
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
