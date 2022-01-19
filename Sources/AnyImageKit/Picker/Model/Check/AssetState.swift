//
//  AssetState.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/16.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public enum AssetState<Resource: IdentifiableResource>: Equatable {
    // unchecked state
    case initialization
    case preselected
    // checked state
    case normal
    case selected
    case disabled(AssetDisableCheckRule<Resource>)
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.initialization, initialization):
            return true
        case (.preselected, .preselected):
            return true
        case (.normal, normal):
            return true
        case (.selected, selected):
            return true
        case (.disabled, disabled):
            return true
        default:
            return false
        }
    }
}

extension AssetState {
    
    var isChecked: Bool {
        switch self {
        case .initialization, .preselected:
            return false
        case .normal, .selected, .disabled:
            return true
        }
    }
}

extension AssetState {
    
    public var isNormal: Bool {
        switch self {
        case .normal:
            return true
        default:
            return false
        }
    }
}

extension AssetState {
    
    public var isSelected: Bool {
        switch self {
        case .selected:
            return true
        default:
            return false
        }
    }
}

extension AssetState {
    
    public var isDisabled: Bool {
        switch self {
        case .disabled:
            return true
        default:
            return false
        }
    }
    
    public var disableCheckRule: AssetDisableCheckRule<Resource>? {
        switch self {
        case .disabled(let rule):
            return rule
        default:
            return nil
        }
    }
}
