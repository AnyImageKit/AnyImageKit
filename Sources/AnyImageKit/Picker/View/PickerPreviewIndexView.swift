//
//  PickerPreviewIndexView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/20.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol PickerPreviewIndexViewDelegate: AnyObject {
    
    func pickerPreviewIndexView(_ view: PickerPreviewIndexView, didSelect asset: Asset)
}

final class PickerPreviewIndexView: UIView {
    
    weak var delegate: PickerPreviewIndexViewDelegate?
    
    var currentAsset: Asset? {
        didSet {
            lastAsset = oldValue
            didSetCurrentAsset()
        }
    }
    
    private var isFirst = true
    private var lastAsset: Asset?
    private var lastAssetList: [Asset] = []
    
    private var selectedAssets: [Asset] {
        switch sourceType {
        case .album:
            return manager.selectedAssets
        case .selectedAssets:
            return manager.lastSelectedAssets
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 64, height: 64)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.showsHorizontalScrollIndicator = false
        view.registerCell(AssetCell.self)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private let manager: PickerManager
    private let sourceType: PhotoPreviewController.SourceType
    
    init(manager: PickerManager, sourceType: PhotoPreviewController.SourceType) {
        self.manager = manager
        self.sourceType = sourceType
        super.init(frame: .zero)
        lastAssetList = manager.selectedAssets
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
    
    private func didSetCurrentAsset() {
        isHidden = selectedAssets.isEmpty
        if let idx = selectedAssets.firstIndex(where: { $0 == currentAsset }) {
            let indexPath = IndexPath(item: idx, section: 0)
            collectionView.reloadItems(at: [indexPath])
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        if let idx = selectedAssets.firstIndex(where: { $0 == lastAsset }) {
            collectionView.reloadItems(at: [IndexPath(item: idx, section: 0)])
        }
    }
}

// MARK: - PickerOptionsConfigurable
extension PickerPreviewIndexView: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        collectionView.backgroundColor = options.theme[color: .toolBar].withAlphaComponent(0.95)
        updateChildrenConfigurable(options: options)
    }
}

extension PickerPreviewIndexView {
    
    func didChangeSelectedAsset() {
        switch sourceType {
        case .album:
            let assetList = selectedAssets
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
        case .selectedAssets:
            collectionView.reloadData()
        }
    }
    
    private func selectItemAtFirstTime() {
        if !isFirst { return }
        isFirst = false
        if let idx = selectedAssets.firstIndex(where: { $0 == currentAsset }) {
            let indexPath = IndexPath(item: idx, section: 0)
            collectionView.reloadItems(at: [indexPath])
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension PickerPreviewIndexView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(AssetCell.self, for: indexPath)
        let asset = selectedAssets[indexPath.item]
        cell.setContent(asset, manager: manager, animated: false, isPreview: true)
        cell.selectButton.isHidden = true
        cell.boxCoverView.isHidden = asset != currentAsset
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PickerPreviewIndexView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pickerPreviewIndexView(self, didSelect: selectedAssets[indexPath.item])
    }
}
