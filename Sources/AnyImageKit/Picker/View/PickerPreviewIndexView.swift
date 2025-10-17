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
    
    private(set) lazy var section = AssetCell.wrapperToSingleTypeSection()
    private(set) lazy var collectionView: SKCollectionView = {
        let view = SKCollectionView()
        view.scrollDirection = .horizontal
        view.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.backgroundColor = manager.options.theme[color: .background]
        view.manager.reload(section)
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
        setupSection()
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
    
    private func setupSection() {
        section.minimumLineSpacing = 12
        section.minimumInteritemSpacing = 12
        section.setCellStyle(on: self) { (self, context) in
            context.view.boxCoverView.isHidden = context.model.asset != self.currentAsset
            context.view.selectButton.isHidden = true
        }
        section.onCellAction(on: self, .selected) { (self, context) in
            self.delegate?.pickerPreviewIndexView(self, didSelect: context.model.asset)
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
    
    func didSetCurrentAsset() {
        isHidden = selectedAssets.isEmpty
        if section.models.isEmpty {
            section.config(models: selectedAssets.map { .init(asset: $0, manager: manager, isPreview: true) })
        }
        UIView.performWithoutAnimation {
            if let idx = selectedAssets.firstIndex(where: { $0 == currentAsset }) {
                section.refresh(at: idx, model: .init(asset: selectedAssets[idx], manager: manager, isPreview: true))
                section.scroll(to: idx, at: .centeredHorizontally, animated: true)
            }
            if let idx = selectedAssets.firstIndex(where: { $0 == lastAsset }) {
                section.refresh(at: idx, model: .init(asset: selectedAssets[idx], manager: manager, isPreview: true))
            }
        }
    }
    
    func didChangeSelectedAsset() {
        switch sourceType {
        case .album:
            let assetList = selectedAssets
            self.isHidden = assetList.isEmpty
            if lastAssetList.count < assetList.count {
                section.insert(at: assetList.count-1, [.init(asset: assetList.last!, manager: manager, isPreview: true)])
                section.scroll(to: assetList.count-1, at: .right, animated: true)
            } else if lastAssetList.count > assetList.count {
                for (idx, asset) in lastAssetList.enumerated() {
                    if !assetList.contains(asset) {
                        section.remove(idx)
                        break
                    }
                }
            }
            lastAssetList = assetList
        case .selectedAssets:
            section.config(models: selectedAssets.map { .init(asset: $0, manager: manager, isPreview: true) })
        }
    }
    
    private func selectItemAtFirstTime() {
        if !isFirst { return }
        isFirst = false
        if let idx = selectedAssets.firstIndex(where: { $0 == currentAsset }) {
            section.refresh(at: idx, model: .init(asset: selectedAssets[idx], manager: manager, isPreview: true))
            section.scroll(to: idx, at: .centeredHorizontally, animated: true)
        }
    }
}
