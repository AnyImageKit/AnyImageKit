//
//  File.swift
//
//
//  Created by linhey on 2024/3/17.
//

import Foundation
import UIKit

/// A type that binds a value using a closure.
public struct SKBindingKey<Value> {
    
    private let closure: () -> Value?
    
    /// The wrapped value obtained from the closure.
    public var wrappedValue: Value? { closure() }

    /// Initializes a new binding key with a closure.
    /// - Parameter closure: A closure that returns the value to be bound.
    /// - Example:
    /// ```
    /// let bindingKey = SKBindingKey<Int> { return 5 }
    /// print(bindingKey.wrappedValue) // Prints "Optional(5)"
    /// ```
    public init(get closure: @escaping () -> Value?) {
        self.closure = closure
    }
    
    /// Initializes a new binding key with a specific value.
    /// - Parameter value: The value to be bound.
    /// - Example:
    /// ```
    /// let bindingKey = SKBindingKey(5)
    /// print(bindingKey.wrappedValue) // Prints "Optional(5)"
    /// ```
    public init(_ value: Value?) {
        self.closure = { value }
    }
}

public extension SKBindingKey {
    /// Creates a constant binding key with a specific value.
    /// - Parameter value: The constant value to be bound.
    /// - Returns: A binding key that always returns the specified value.
    /// - Example:
    /// ```
    /// let constantKey = SKBindingKey.constant(10)
    /// print(constantKey.wrappedValue) // Prints "Optional(10)"
    /// ```
    static func constant(_ value: Value) -> SKBindingKey<Value> {
        .init(get: { value })
    }
}

public extension SKBindingKey where Value == Int {
    
    /// A constant binding key representing all sections.
    static let all = SKBindingKey.constant(-1000000)

    /// Creates a relative binding key from a collection view and a key path.
    /// - Parameters:
    ///   - view: The collection view.
    ///   - path: The key path to get the relative value from the range of sections.
    /// - Returns: A binding key that gets the relative section index.
    /// - Example:
    /// ```
    /// let collectionView: UICollectionView? = ...
    /// let relativeKey = SKBindingKey.relative(from: collectionView, \.first)
    /// print(relativeKey.wrappedValue)
    /// ```
    static func relative(from view: UICollectionView?, _ task: @escaping (_ range: Range<Int>) -> Int?) -> Self {
       return .init(get: { [weak view] in
            guard let view = view else {
                return nil
            }
            return task(0..<view.numberOfSections)
        })
    }
    
    
    /// Initializes a new binding key with a section action protocol and an offset.
    /// - Parameters:
    ///   - section: The section action protocol.
    ///   - offset: The offset to be added to the section index. Defaults to 0.
    /// - Example:
    /// ```
    /// let section: SKCSectionActionProtocol = ...
    /// let sectionKey = SKBindingKey(section, offset: 1)
    /// print(sectionKey.wrappedValue)
    /// ```
    init(_ section: SKCSectionActionProtocol, offset: Int = 0) {
        self.init(get: { [weak section] in
            guard let section = section, let injection = section.sectionInjection else {
                return nil
            }
            return injection.index + offset
        })
    }
}

extension SKBindingKey: Equatable where Value: Equatable {
    
    /// Checks if two binding keys are equal.
    /// - Parameters:
    ///   - lhs: The left-hand side binding key.
    ///   - rhs: The right-hand side binding key.
    /// - Returns: `true` if the wrapped values are equal, otherwise `false`.
    /// - Example:
    /// ```
    /// let key1 = SKBindingKey(5)
    /// let key2 = SKBindingKey(5)
    /// print(key1 == key2) // Prints "true"
    /// ```
    public static func == (lhs: SKBindingKey<Value>,
                           rhs: SKBindingKey<Value>) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
    
}

extension SKBindingKey: Hashable where Value: Hashable {
    
    /// Hashes the wrapped value into the provided hasher.
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    /// - Example:
    /// ```
    /// let key = SKBindingKey(5)
    /// var hasher = Hasher()
    /// key.hash(into: &hasher)
    /// print(hasher.finalize())
    /// ```
    public func hash(into hasher: inout Hasher) {
        hasher.combine(closure())
    }
}
