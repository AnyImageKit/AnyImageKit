//
//  PickerManager+State.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/29.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Photos

extension PickerManager {
    
    @discardableResult
    func checkState(for asset: Asset<PHAsset>) -> AssetState {
        if let state = states[asset.identifier] {
            return state
        } else {
            for rule in options.disableRules {
                if rule.isDisable(for: asset) {
                    return updateState(for: asset, disable: rule)
                }
            }
            return updateState(for: asset, isSelected: false)
        }
    }
    
    @discardableResult
    func updateState(for asset: Asset<PHAsset>, isSelected: Bool) -> AssetState {
        let newState: AssetState = isSelected ? .selected : .normal
        states[asset.identifier] = newState
        return newState
    }
    
    @discardableResult
    func updateState(for asset: Asset<PHAsset>, disable rule: AssetDisableCheckRule) -> AssetState {
        let newState: AssetState = .disable(rule)
        states[asset.identifier] = newState
        return newState
    }
    
    func selectedNum(for asset: PhotoAsset) -> Int {
        return selectedAssets.firstIndex(of: asset) ?? 0
    }
}
