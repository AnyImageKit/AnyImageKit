//
//  IdentifiableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/9.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public protocol IdentifiableResource: Hashable {
    
    var identifier: String { get }
}

// MARK: - Equatable
extension IdentifiableResource {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

// MARK: - Hashable
extension IdentifiableResource {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
