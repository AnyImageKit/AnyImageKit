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
                    states[asset.identifier] = .disable(rule)
                    return .disable(rule)
                }
            }
            states[asset.identifier] = .normal
            return .normal
        }
    }
}
