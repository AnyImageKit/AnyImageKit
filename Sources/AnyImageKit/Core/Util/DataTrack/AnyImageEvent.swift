//
//  AnyImageEvent.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/10/19.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public struct AnyImageEvent: Equatable, RawRepresentable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension AnyImageEvent: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

public struct AnyImageEventUserInfoKey: Hashable, RawRepresentable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension AnyImageEventUserInfoKey: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

extension AnyImageEventUserInfoKey {
    
    /// Value: Bool
    public static let isOn: AnyImageEventUserInfoKey = "ANYIMAGEKIT_USERINFO_IS_ON"
    
    /// Value: AnyImagePage
    public static let page: AnyImageEventUserInfoKey = "ANYIMAGEKIT_USERINFO_PAGE"
}
