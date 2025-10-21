//
//  AssetSection.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/17.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit

final class AssetSection: SKCSectionProtocol {
    
    typealias AssetSectionCallback = (index: Int, asset: Asset)
    
    let selectedEvent = Delegate<AssetSectionCallback, Void>()
    let openCaptureEvent = Delegate<Void, Void>()
    let openEditorEvent = Delegate<AssetSectionCallback, Void>()
    let openPreviewEvent = Delegate<AssetSectionCallback, Void>()
    let showAlertEvent = Delegate<String, Void>()
    let configCellEvent = Delegate<AssetCell, Void>()
    
    private enum CellType {
        case asset(AssetCell.Model)
        case camera(CameraCell.Model)
    }
    
    private var cellTypes: [CellType] = []
    var itemCount: Int { cellTypes.count }
    var minimumLineSpacing: CGFloat = 2
    var minimumInteritemSpacing: CGFloat = 2
    var sectionInjection: SKCSectionInjection?
    
    private let manager: PickerManager
    private(set) var assets: [Asset] = []
    private var columnCount: CGFloat = 4
    private var hasCamera = false
    
    var itemOffset: Int {
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        switch manager.options.orderByDate {
        case .asc:
            return 0
        case .desc:
            guard !manager.options.captureOptions.mediaOptions.isEmpty else { return 0 }
            return hasCamera ? 1 : 0
        }
        #else
        return 0
        #endif
    }
    
    init(manager: PickerManager) {
        self.manager = manager
    }
    
}

// MARK: - Public function
extension AssetSection {
    
    func config(assets: [Asset], columnCount: Int) {
        self.assets = assets
        self.columnCount = CGFloat(columnCount)
        self.hasCamera = false
        cellTypes = assets.map {
            if $0.isCamera {
                self.hasCamera = true
                return .camera(())
            } else {
                return .asset(.init(asset: $0, manager: manager))
            }
        }
        reload()
    }
    
}

// MARK: - Config
extension AssetSection {
    
    func config(sectionView: UICollectionView) {
        register(AssetCell.self)
        register(CameraCell.self)
    }
    
    func item(at row: Int) -> UICollectionViewCell {
        switch cellTypes[row] {
        case .asset(let model):
            let cell = dequeue(at: row) as AssetCell
            cell.config(model)
            cell.selectEvent.delegate(on: self) { (self, _) in
                self.selectedEvent.call((row, self.assets[row]))
            }
            cell.backgroundColor = UIColor.white
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = .button
            let accessibilityLabel = manager.options.theme[string: model.asset.mediaType == .video ? .video : .photo]
            cell.accessibilityLabel = "\(accessibilityLabel)\(row)"
            configCellEvent.call(cell)
            return cell
        case .camera(let model):
            let cell = dequeue(at: row) as CameraCell
            cell.config(model)
            cell.update(options: manager.options)
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = .button
            cell.accessibilityLabel = manager.options.theme[string: .pickerTakePhoto]
            return cell
        }
    }
    
    func itemSize(at row: Int) -> CGSize {
        let size = defaultSafeSizeProvider.size
        let spacing: CGFloat = 2
        let itemWidth = ceil((size.width - (columnCount - 1) * spacing) / columnCount)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func item(willDisplay view: UICollectionViewCell, row: Int) {
        guard let cell = view as? AssetCell else { return }
        cell.updateState(assets[row], manager: manager, animated: false)
    }
    
    func item(didEndDisplaying view: UICollectionViewCell, row: Int) {
        guard let _ = view as? AssetCell else { return }
        if row < assets.count {
            assets[row].cleanImageIfNeeded()
        }
    }
    
    func item(selected row: Int) {
        let asset = assets[row]
#if ANYIMAGEKIT_ENABLE_CAPTURE
        if asset.isCamera { // 点击拍照 Item
            openCaptureEvent.call()
            return
        }
#endif
#if ANYIMAGEKIT_ENABLE_EDITOR
        if manager.options.selectionTapAction == .openEditor && canOpenEditor(with: asset) {
            openEditorEvent.call((row, asset))
            return
        }
#endif
        
        if manager.options.selectionTapAction == .quickPick {
            selectedEvent.call((row, asset))
        } else if case .disable(let rule) = asset.state {
            let message = rule.alertMessage(for: asset, assetList: manager.selectedAssets)
            showAlertEvent.call(message)
            return
        } else if !asset.isSelected && manager.isUpToLimit {
            return
        } else {
            openPreviewEvent.call((row, asset))
        }
    }
    
#if ANYIMAGEKIT_ENABLE_EDITOR
    func canOpenEditor(with asset: Asset) -> Bool {
        asset.check(disable: manager.options.disableRules, assetList: manager.selectedAssets)
        if case .disable(let rule) = asset.state {
            let message = rule.alertMessage(for: asset, assetList: manager.selectedAssets)
            showAlertEvent.call(message)
            return false
        }
        if asset.mediaType == .photo && manager.options.editorOptions.contains(.photo) {
            return true
        } else if asset.phAsset.mediaType == .video && manager.options.editorOptions.contains(.video) {
            return true
        }
        return false
    }
#endif
}
