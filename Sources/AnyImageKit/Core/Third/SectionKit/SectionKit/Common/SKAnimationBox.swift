//
//  DUISelection.swift
//  iDxyer
//
//  Created by linhey on 5/9/25.
//  Copyright © 2025 dxy.cn. All rights reserved.
//

public struct SKAnimationBox<Value> {
    
    public var value: Value
    public var isEnabled: Bool
    public var animation: Bool

    public init(value: Value, animation: Bool = false, isEnabled: Bool = true) {
        self.value = value
        self.animation = animation
        self.isEnabled = isEnabled
    }
}

extension SKAnimationBox: ExpressibleByIntegerLiteral where Value == Int {
    
    public init(integerLiteral value: Int) {
        self.init(value: value, animation: false)
    }
    
}

// MARK: - ExpressibleByFloatLiteral for Double values
extension SKAnimationBox: ExpressibleByFloatLiteral where Value == Double {
    public init(floatLiteral value: Double) {
        self.init(value: value, animation: false)
    }
}

// MARK: - ExpressibleByBooleanLiteral for Bool values
extension SKAnimationBox: ExpressibleByBooleanLiteral where Value == Bool {
    public init(booleanLiteral value: Bool) {
        self.init(value: value, animation: false)
    }
}

// MARK: - ExpressibleByNilLiteral for Optional values
extension SKAnimationBox: ExpressibleByNilLiteral where Value == Optional<Any> {
    public init(nilLiteral: ()) {
        self.init(value: nil, animation: false)
    }
}
