//
//  PickerPreviewIndexView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/20.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol PickerPreviewIndexViewDelegate: AnyObject {
    
    func pickerPreviewIndexView(_ view: PickerPreviewIndexView, didSelect idx: Int)
}

final class PickerPreviewIndexView: UIView {
    
    weak var delegate: PickerPreviewIndexViewDelegate?
    
    var currentIndex: Int = 0 {
        didSet {
            lastIdx = oldValue
            didSetCurrentIndex()
        }
    }
    
    private var isFirst = true
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
        view.backgroundColor = options.theme.toolBarColor.withAlphaComponent(0.95)
        view.showsHorizontalScrollIndicator = false
        view.registerCell(AssetCell.self)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private let options: PickerOptionsInfo
    
    private var manager: PickerManager!
    
    init(frame: CGRect, options: PickerOptionsInfo) {
        self.options = options
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectItemAtFirstTime()
    }
    
    private func setupView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
    
    func setManager(_ manager: PickerManager) {
        self.manager = manager
        lastAssetList = manager.selectedAssets
    }
    
    private func didSetCurrentIndex() {
        isHidden = manager.selectedAssets.isEmpty
        if let idx = manager.selectedAssets.firstIndex(where: { $0.idx == currentIndex }) {
            let indexPath = IndexPath(item: idx, section: 0)
            collectionView.reloadItems(at: [indexPath])
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        if let idx = manager.selectedAssets.firstIndex(where: { $0.idx == lastIdx }) {
            collectionView.reloadItems(at: [IndexPath(item: idx, section: 0)])
        }
    }
}

extension PickerPreviewIndexView {
    
    func didChangeSelectedAsset() {
        let assetList = manager.selectedAssets
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
    
    private func selectItemAtFirstTime() {
        if !isFirst { return }
        isFirst = false
        if let idx = manager.selectedAssets.firstIndex(where: { $0.idx == currentIndex }) {
            let indexPath = IndexPath(item: idx, section: 0)
            collectionView.reloadItems(at: [indexPath])
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
}

extension PickerPreviewIndexView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager.selectedAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(AssetCell.self, for: indexPath)
        let asset = manager.selectedAssets[indexPath.item]
        cell.setContent(asset, manager: manager, animated: false, isPreview: true)
        cell.selectButton.isHidden = true
        cell.boxCoverView.isHidden = asset.idx != currentIndex
        return cell
    }
}

extension PickerPreviewIndexView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pickerPreviewIndexView(self, didSelect: manager.selectedAssets[indexPath.item].idx)
    }
}
