//
//  PhotoLibraryAssetCollection+State.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/21.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import Photos

extension PhotoLibraryAssetCollection {
    
    func checkState(asset: Asset<PHAsset>) {
        checker.check(asset: asset)
    }
    
    func reset() {
        checker.reset()
    }
}

extension PhotoLibraryAssetCollection {
    
    
    var selectItems: [Asset<PHAsset>] {
        checker.selectedItems
    }
    
    func setSelected(asset: Asset<PHAsset>) throws {
        let state = asset.state
        switch state {
        case .normal:
            if checker.isUpToLimit {
                if selectOption.isPhoto && selectOption.isVideo {
                    throw AssetSelectedError<PHAsset>.maximumOfPhotosOrVideos
                } else if selectOption.isPhoto {
                    throw AssetSelectedError<PHAsset>.maximumOfPhotos
                } else {
                    throw AssetSelectedError<PHAsset>.maximumOfVideos
                }
            } else {
                checker.setSelected(asset: asset, isSelected: true)
            }
        case .selected:
            checker.setSelected(asset: asset, isSelected: false)
        case .disabled(let rule):
            throw AssetSelectedError<PHAsset>.disabled(rule)
        }
    }
}
