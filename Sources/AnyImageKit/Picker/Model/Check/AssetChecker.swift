//
//  AssetChecker.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/16.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

final class AssetChecker<Resource: IdentifiableResource> {
    
    private let limitCount: Int
    private let preselectedIdentifiers: [String]
    private let disableCheckRules: [AssetDisableCheckRule<Resource>]
    
    private let storage: Storage<Resource> = .init()
    
    init(limitCount: Int, preselectedIdentifiers: [String], disableCheckRules: [AssetDisableCheckRule<Resource>]) {
        self.limitCount = limitCount
        self.preselectedIdentifiers = preselectedIdentifiers
        self.disableCheckRules = disableCheckRules
    }
}

extension AssetChecker {
    
    var context: AssetCheckContext<Resource> {
        return .init(selectedAssets: storage.selectedItems)
    }
    
    func check(asset: Asset<Resource>) {
        if let state = storage.states[asset.identifier] {
            switch state {
            case .normal:
                if let rule = checkDisabled(asset: asset, context: context) {
                    updateStorage(state: .disabled(rule), asset: asset)
                }
            case .selected:
                break
            case .disabled:
                if let rule = checkDisabled(asset: asset, context: context) {
                    updateStorage(state: .disabled(rule), asset: asset)
                } else {
                    updateStorage(state: .normal, asset: asset)
                }
            }
        } else if let rule = checkDisabled(asset: asset, context: context) {
            updateStorage(state: .disabled(rule), asset: asset)
        } else if preselectedIdentifiers.contains(asset.identifier) {
            updateStorage(state: .selected, asset: asset)
        } else {
            updateStorage(state: .normal, asset: asset)
        }
    }
    
    private func checkDisabled(asset: Asset<Resource>, context: AssetCheckContext<Resource>) -> AssetDisableCheckRule<Resource>? {
        for rule in disableCheckRules where rule.isDisable(for: asset, context: context) {
            return rule
        }
        return nil
    }
}

extension AssetChecker {
    
    func loadState(asset: Asset<Resource>) -> AssetState<Resource> {
        guard let state = storage.states[asset.identifier] else {
            fatalError("Asset Collection must check asset before return!")
        }
        return state
    }
}

extension AssetChecker {
    
    var isUpToLimit: Bool {
        selectedItems.count == limitCount
    }
    
    var selectedItems: [Asset<Resource>] {
        storage.selectedItems
    }
    
    func selectedNumber(asset: Asset<Resource>) -> Int? {
        if let index = storage.selectedItems.firstIndex(of: asset) {
            return index + 1
        }
        return nil
    }
    
    func setSelected(asset: Asset<Resource>, isSelected: Bool) {
        guard let state = storage.states[asset.identifier], !state.isDisabled else {
            return
        }
        if isSelected {
            updateStorage(state: .selected, asset: asset)
        } else {
            updateStorage(state: .normal, asset: asset)
        }
    }
}

extension AssetChecker {
    
    func reset() {
        storage.selectedItems.removeAll()
        storage.states.removeAll()
    }
    
    private func updateStorage(state: AssetState<Resource>, asset: Asset<Resource>){
        storage.states[asset.identifier] = state
        // update selectedItems
        if state.isSelected, !storage.selectedItems.contains(asset) {
            storage.selectedItems.append(asset)
        } else if !state.isSelected, let index = storage.selectedItems.firstIndex(of: asset) {
            storage.selectedItems.remove(at: index)
        }
    }
}

extension AssetChecker {
    
    private class Storage<Resource: IdentifiableResource> {
        
        var states: [String: AssetState<Resource>] = [:]
        var selectedItems: [Asset<Resource>] = []
        
        init() { }
    }
}
