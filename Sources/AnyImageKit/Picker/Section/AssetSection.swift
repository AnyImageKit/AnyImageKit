//
//  AssetSection.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/17.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit

final class AssetSection: SKCSectionProtocol, SKCViewDataSourcePrefetchingProtocol {
    
    typealias AssetSectionCallback = (index: Int, asset: Asset)
    
    let selectedEvent = Delegate<AssetSectionCallback, Void>()
    let openCaptureEvent = Delegate<Void, Void>()
    let openEditorEvent = Delegate<AssetSectionCallback, Void>()
    let openPreviewEvent = Delegate<AssetSectionCallback, Void>()
    let showAlertEvent = Delegate<String, Void>()
    let configCellEvent = Delegate<AssetCell, Void>()
    
    var itemCount: Int { album?.itemCount ?? 0 }
    var minimumLineSpacing: CGFloat = 2
    var minimumInteritemSpacing: CGFloat = 2
    var sectionInjection: SKCSectionInjection?
    
    private let manager: PickerManager
    private var album: Album?
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
    
    func config(album: Album?, columnCount: Int) {
        self.album = album
        self.columnCount = CGFloat(columnCount)
        self.hasCamera = album?.hasCamera ?? false
        reload()
    }

    func asset(at row: Int) -> Asset? {
        guard let album, let asset = album.asset(at: row) else { return nil }
        if let selectedAsset = manager.selectedAssets.first(where: { $0.identifier == asset.identifier }), selectedAsset !== asset {
            album.cache(selectedAsset)
            return selectedAsset
        }
        return asset
    }
    
}

// MARK: - Config
extension AssetSection {
    
    func config(sectionView: UICollectionView) {
        register(AssetCell.self)
        register(CameraCell.self)
    }
    
    func item(at row: Int) -> UICollectionViewCell {
        guard let asset = asset(at: row) else { return dequeue(at: row) as AssetCell }
        if asset.isCamera {
            let cell = dequeue(at: row) as CameraCell
            cell.config(())
            cell.update(options: manager.options)
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = .button
            cell.accessibilityLabel = manager.options.theme[string: .pickerTakePhoto]
            return cell
        } else {
            let model = AssetCell.Model(asset: asset, manager: manager)
            let cell = dequeue(at: row) as AssetCell
            cell.config(model)
            cell.selectEvent.delegate(on: self) { (self, _) in
                guard let asset = self.asset(at: row) else { return }
                self.selectedEvent.call((row, asset))
            }
            cell.backgroundColor = UIColor.white
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = .button
            let accessibilityLabel = manager.options.theme[string: model.asset.mediaType == .video ? .video : .photo]
            cell.accessibilityLabel = "\(accessibilityLabel)\(row)"
            configCellEvent.call(cell)
            return cell
        }
    }
    
    func itemSize(at row: Int) -> CGSize {
        let size = defaultSafeSizeProvider.size
        let spacing: CGFloat = 2
        // Use floor so the total width never exceeds the available row width.
        let itemWidth = max(0, floor((size.width - (columnCount - 1) * spacing) / columnCount))
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func item(willDisplay view: UICollectionViewCell, row: Int) {
        guard let cell = view as? AssetCell, let asset = asset(at: row) else { return }
        cell.updateState(asset, manager: manager, animated: false)
    }
    
    func item(didEndDisplaying view: UICollectionViewCell, row: Int) {
        guard let _ = view as? AssetCell else { return }
        asset(at: row)?.cleanImageIfNeeded()
    }
    
    func item(selected row: Int) {
        guard let asset = asset(at: row) else { return }
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

    func prefetch(at rows: [Int]) {
        rows.forEach { _ = asset(at: $0) }
    }

    func cancelPrefetching(at rows: [Int]) { }
    
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
