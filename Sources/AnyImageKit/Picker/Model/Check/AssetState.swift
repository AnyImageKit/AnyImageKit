//
//  AssetState.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/16.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

enum AssetState<Resource: IdentifiableResource>: Equatable {
    
    case normal
    case selected
    case disabled(AssetDisableCheckRule<Resource>)
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
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
    
    var isNormal: Bool {
        switch self {
        case .normal:
            return true
        default:
            return false
        }
    }
}

extension AssetState {
    
    var isSelected: Bool {
        switch self {
        case .selected:
            return true
        default:
            return false
        }
    }
}

extension AssetState {
    
    var isDisabled: Bool {
        switch self {
        case .disabled:
            return true
        default:
            return false
        }
    }
    
    var disableCheckRule: AssetDisableCheckRule<Resource>? {
        switch self {
        case .disabled(let rule):
            return rule
        default:
            return nil
        }
    }
}
