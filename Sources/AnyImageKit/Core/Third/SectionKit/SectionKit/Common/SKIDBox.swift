//
//  SKIDBox.swift
//  SectionKit2
//
//  Created by linhey on 2023/12/15.
//

import Foundation

public struct SKIDBox<ID, Value> {
    
    public typealias ID = ID
    public let id: ID
    public let value: Value
    
    public init(id: ID, value: Value) {
        self.id = id
        self.value = value
    }
    
    public init(value: Value) where ID == UUID {
        self.id = UUID()
        self.value = value
    }
    
}
