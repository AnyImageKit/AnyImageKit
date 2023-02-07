//
//  File.swift
//  
//
//  Created by linhey on 2022/8/15.
//

import Foundation

public final class SKCRegistrationInjection: SKCRegistrationInjectionProtocol {
    

    public struct Action: OptionSet, SKCRegistrationInjectionActionProtocol {
        
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
    }
    
    public var index: Int
    public var events: [Action: (SKCRegistrationInjection) -> Void]

    public init(index: Int,
                events: [Action : (SKCRegistrationInjection) -> Void] = [:]) {
        self.index = index
        self.events = events
    }
    
}

public extension SKCRegistrationInjection.Action {
    
    static let reload = Self(rawValue: 1 << 1)
    static let delete = Self(rawValue: 1 << 2)
    
}
