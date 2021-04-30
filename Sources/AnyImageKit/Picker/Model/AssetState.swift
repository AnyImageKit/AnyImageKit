//
//  AssetState.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/29.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

enum AssetState {
    
    case normal
    case selected
    case disable(AssetDisableCheckRule)
}

extension AssetState: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.normal, normal):
            return true
        case (.selected, selected):
            return true
        case (.disable, disable):
            return true
        default:
            return false
        }
    }
}

extension AssetState {
    
    var isSelected: Bool {
        return self == .selected
    }
    
    var isDisable: Bool {
        switch self {
        case .disable(_):
            return true
        default:
            return false
        }
    }
}
