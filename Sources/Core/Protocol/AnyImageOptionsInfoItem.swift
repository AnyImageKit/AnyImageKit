//
//  AnyImageOptionsInfoItem.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

infix operator ~== : LogicalConjunctionPrecedence

public protocol AnyImageOptionsInfoItem {
    
    static func ~== (lhs: Self, rhs: Self) -> Bool
}

extension Array where Element: AnyImageOptionsInfoItem {
    
    public mutating func update(_ element: Element) {
        if let idx = (self.firstIndex{ $0 ~== element }) {
            self.remove(at: idx)
        }
        self.append(element)
    }
}
