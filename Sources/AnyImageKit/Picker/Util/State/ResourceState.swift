//
//  ResourceState.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/25.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

enum ResourceState<Resource: LoadableResource>: Equatable {
    
    case initialize
    case normal
    case selected
    case edited
    case disabled(AnyResourceDisableCheckRule<Resource>)
    
    var isDisabled: Bool {
        switch self {
        case .disabled:
            return true
        default:
            return false
        }
    }
}
