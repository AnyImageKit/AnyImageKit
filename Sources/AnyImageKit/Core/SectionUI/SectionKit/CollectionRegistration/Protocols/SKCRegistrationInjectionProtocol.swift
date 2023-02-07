//
//  File.swift
//  
//
//  Created by linhey on 2022/8/17.
//

import Foundation

public protocol SKCRegistrationInjectionActionProtocol: Hashable {
    static var reload: Self { get }
    static var delete: Self { get }
}

public protocol SKCRegistrationInjectionProtocol {
    
    associatedtype Action: SKCRegistrationInjectionActionProtocol
    var index: Int { get }
    var events: [Action: (Self) -> Void] { get set }
    
}
         
public extension SKCRegistrationInjectionProtocol {
    
    mutating func add(_ action: Action, block: ((Self) -> Void)?) {
        self.events[action] = block
    }
    
    mutating func reset(_ events: [Action: (Self) -> Void]) {
        self.events = events
    }
    
    func reload() {
        send(.reload)
    }
    
    func delete() {
        send(.delete)
    }
    
    func send(_ action: Action) {
        guard let event = events[action] else {
            assertionFailure()
            return
        }
        event(self)
    }
}
