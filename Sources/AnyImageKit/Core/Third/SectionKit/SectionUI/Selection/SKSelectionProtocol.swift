//
//  File.swift
//  
//
//  Created by linhey on 2022/9/8.
//

import Foundation
import Combine

public protocol SKSelectionProtocol {
    var selection: SKSelectionState { get }
}

public extension SKSelectionProtocol {
    
    var isSelected: Bool {
        selection.isSelected
    }

    var canSelect: Bool {
        get { selection.canSelect }
        nonmutating set { selection.canSelect = newValue }
    }

    /// 是否允许选中或取消选中操作
    var isEnabled: Bool {
        get { selection.isEnabled }
        nonmutating set { selection.isEnabled = newValue }
    }
    
    var selectedPublisher:  AnyPublisher<Bool, Never> { selection.selectedPublisher }
    var canSelectPublisher: AnyPublisher<Bool, Never> { selection.canSelectPublisher }
    var enabledPublisher: AnyPublisher<Bool, Never> { selection.enabledPublisher }
    var changedPublisher:   AnyPublisher<SKSelectionState, Never> { selection.changedPublisher }
    
    func toggle() {
        select(!isSelected)
    }
    
    @discardableResult
    func select(_ value: Bool) -> Bool {
        if value {
            if canSelect {
                self.selection.isSelected = canSelect
            }
            return canSelect
        } else {
            self.selection.isSelected = false
            return true
        }
    }
    
}
