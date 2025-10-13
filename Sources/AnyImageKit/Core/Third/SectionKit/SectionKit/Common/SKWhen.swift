//
//  File.swift
//
//
//  Created by linhey on 2024/6/19.
//

import Foundation

/// 泛型结构体，用于定义条件判断
public struct SKWhen<Object> {
    
    /// 条件判断闭包
    public let isIncluded: (_ object: Object) -> Bool
    
    /// 初始化方法
    ///
    /// - Parameter isIncluded: 判断条件的闭包
    public init(_ isIncluded: @escaping (_ object: Object) -> Bool) {
        self.isIncluded = isIncluded
    }
    
}

public extension SKWhen {
    
    /// 逻辑与组合方法
    ///
    /// - Parameter other: 另一个 SKWhen 实例
    /// - Returns: 一个新的 SKWhen 实例，包含两个条件的逻辑与组合
    func and(_ other: SKWhen) -> SKWhen {
        return SKWhen { object in
            self.isIncluded(object) && other.isIncluded(object)
        }
    }
    
    /// 逻辑或组合方法
    ///
    /// - Parameter other: 另一个 SKWhen 实例
    /// - Returns: 一个新的 SKWhen 实例，包含两个条件的逻辑或组合
    func or(_ other: SKWhen) -> SKWhen {
        return SKWhen { object in
            self.isIncluded(object) || other.isIncluded(object)
        }
    }
    
}

public extension SKWhen {
    
    /// 静态方法，用于比较对象的某个属性值是否等于指定值
    ///
    /// - Parameters:
    ///   - keyPath: 对象属性的键路径
    ///   - value: 要比较的值
    /// - Returns: 一个新的 SKWhen 实例
    static func equal<V: Equatable>(_ keyPath: KeyPath<Object, V>, _ value: V) -> SKWhen<Object> {
        return .init({ $0[keyPath: keyPath] == value })
    }
    
    /// 静态方法，用于比较对象的某个属性值与指定值之间的关系
    ///
    /// - Parameters:
    ///   - keyPath: 对象属性的键路径
    ///   - value: 要比较的值
    ///   - compare: 比较闭包，定义如何比较属性值与指定值
    /// - Returns: 一个新的 SKWhen 实例
    static func compare<V: Comparable>(_ keyPath: KeyPath<Object, V>,
                                       _ value: V,
                                       _ compare: @escaping (V, V) -> Bool) -> SKWhen<Object> {
        return .init({ compare($0[keyPath: keyPath], value) })
    }
    
}
