//
//  AnyImagePage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/10/19.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public struct AnyImagePage: Equatable, RawRepresentable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension AnyImagePage: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

extension AnyImagePage {
    
    static let undefined: AnyImagePage = "ANYIMAGEKIT_PAGE_CORE_UNDEFINED"
}

public enum AnyImagePageState: Equatable {
    
    case enter
    case leave
}
