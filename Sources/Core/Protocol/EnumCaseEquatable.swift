//
//  EnumCaseEquatable.swift
//  AnyImageKit
//
//  Created by Ray on 2019/12/28.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

infix operator ~== : LogicalConjunctionPrecedence

public protocol EnumCaseEquatable: Equatable {
    static func ~== (lhs: Self, rhs: Self) -> Bool
}

extension EnumCaseEquatable {
    public static func ~== (lhs: Self, rhs: Self) -> Bool {
        let m1 = Mirror(reflecting: lhs)
        let m2 = Mirror(reflecting: rhs)
        guard let style = m1.displayStyle, style == .enum else { return false }
        guard let l1 = m1.children.first?.label, let l2 = m2.children.first?.label else {
            return lhs == rhs // 没关联值的枚举没有children，直接比较
        }
        return l1 == l2
    }
}
