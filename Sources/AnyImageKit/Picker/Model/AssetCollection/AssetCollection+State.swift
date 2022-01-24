//
//  AssetCollection+State.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/21.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import Photos

extension AssetCollection {
    
    public func checkState(asset: Asset<Resource>) {
        checker.check(asset: asset)
    }
    
    public func reset() {
        checker.reset()
    }
}

extension AssetCollection {
    
    public var selectedItems: [Asset<Resource>] {
        checker.selectedItems
    }
    
    public func setSelected(asset: Asset<Resource>) throws {
        let state = asset.state
        switch state {
        case .normal:
            if checker.isUpToLimit {
                if selectOption.isPhoto && selectOption.isVideo {
                    throw AssetSelectedError<Resource>.maximumOfPhotosOrVideos
                } else if selectOption.isPhoto {
                    throw AssetSelectedError<Resource>.maximumOfPhotos
                } else {
                    throw AssetSelectedError<Resource>.maximumOfVideos
                }
            } else {
                checker.setSelected(asset: asset, isSelected: true)
            }
        case .selected:
            checker.setSelected(asset: asset, isSelected: false)
        case .disabled(let rule):
            throw AssetSelectedError<Resource>.disabled(rule)
        }
    }
}
