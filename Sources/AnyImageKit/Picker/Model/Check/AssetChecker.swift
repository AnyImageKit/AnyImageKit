//
//  AssetChecker.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/16.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

struct AssetChecker<Resource: IdentifiableResource> {
    
    private let storage: Storage<Resource> = .init()
    
    init() { }
}

extension AssetChecker {
    
    func state(asset: Asset<Resource>) -> AssetState<Resource> {
        if let state = storage.states[asset.identifier] {
            return state
        } else {
            return .initialization
        }
    }
    
    func check(asset: Asset<Resource>, context: AssetCheckContext<Resource>) -> AssetState<Resource> {
        if let state = storage.states[asset.identifier] {
            switch state {
            case .initialization:
                assertionFailure("Should Never Happened Here!")
                return updateStorage(state: .normal, asset: asset)
            case .preselected:
                if let rule = checkDisabled(asset: asset, context: context) {
                    return updateStorage(state: .disabled(rule), asset: asset)
                } else {
                    return updateStorage(state: .selected, asset: asset)
                }
            case .normal, .disabled:
                if let rule = checkDisabled(asset: asset, context: context) {
                    return updateStorage(state: .disabled(rule), asset: asset)
                }else {
                    return updateStorage(state: .normal, asset: asset)
                }
            case .selected:
                return state
            }
        } else if let rule = checkDisabled(asset: asset, context: context) {
            return updateStorage(state: .disabled(rule), asset: asset)
        } else {
            return updateStorage(state: .normal, asset: asset)
        }
    }
}

extension AssetChecker {
    
    func reset(preselected identifiers: [String], disableCheckRules: [AssetDisableCheckRule<Resource>]) {
        storage.selectedItems.removeAll()
        storage.disableCheckRules = disableCheckRules
        storage.states.removeAll()
        for identifier in identifiers {
            storage.states[identifier] = .preselected
        }
    }
}

extension AssetChecker {
    
    func selectedNumber(asset: Asset<Resource>) -> Int? {
        if let index = storage.selectedItems.firstIndex(of: asset.identifier) {
            return index + 1
        }
        return nil
    }
    
    func setSelected(asset: Asset<Resource>, isSelected: Bool) {
        guard let state = storage.states[asset.identifier], state.isChecked, !state.isDisabled else {
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
    
    private func checkDisabled(asset: Asset<Resource>, context: AssetCheckContext<Resource>) -> AssetDisableCheckRule<Resource>? {
        for rule in storage.disableCheckRules where rule.isDisable(for: asset, context: context) {
            return rule
        }
        return nil
    }
    
    @discardableResult
    private func updateStorage(state: AssetState<Resource>, asset: Asset<Resource>) -> AssetState<Resource> {
        storage.states[asset.identifier] = state
        // update selectedItems
        if state.isSelected, !storage.selectedItems.contains(asset.identifier) {
            storage.selectedItems.append(asset.identifier)
        } else if !state.isSelected, let index = storage.selectedItems.firstIndex(of: asset.identifier) {
            storage.selectedItems.remove(at: index)
        }
        return state
    }
}

extension AssetChecker {
    
    private class Storage<Resource: IdentifiableResource> {
        
        var disableCheckRules: [AssetDisableCheckRule<Resource>] = []
        var states: [String: AssetState<Resource>] = [:]
        var selectedItems: [String] = []
        
        init() { }
    }
}
