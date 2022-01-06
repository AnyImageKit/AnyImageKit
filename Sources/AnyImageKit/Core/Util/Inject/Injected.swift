//
//  Injected.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2022/1/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

@propertyWrapper
struct Injected<T> {
    
    private let keyPath: WritableKeyPath<InjectedValues, T>
    
    var wrappedValue: T {
        get { InjectedValues[keyPath] }
        set { InjectedValues[keyPath] = newValue }
    }
    
    init(_ keyPath: WritableKeyPath<InjectedValues, T>) {
        self.keyPath = keyPath
    }
}
