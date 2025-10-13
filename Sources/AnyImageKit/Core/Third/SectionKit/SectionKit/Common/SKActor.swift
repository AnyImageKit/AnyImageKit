//
//  File.swift
//  SectionKit
//
//  Created by linhey on 1/7/25.
//

import Foundation

public actor SKActorBox<Value> {
    
    private var wrappedValue: Value
    
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public var value: Value {
        wrappedValue
    }
    
    public func update(_ value: Value) {
        wrappedValue = value
    }
    
}
