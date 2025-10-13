//
//  SKEnvironmentConfiguration.swift
//  SectionKit
//
//  Created by linhey on 7/16/25.
//

import Foundation

public protocol SKEnvironmentConfiguration: AnyObject {
    var environmentObject: [ObjectIdentifier: Any] { get set }
}

public extension SKEnvironmentConfiguration {
    
    func environment<T>(of type: T.Type) -> T? {
        environmentObject[.init(type)] as? T
    }
    
    func environment<T>(of object: T) {
        environmentObject[.init(T.self)] = object
    }
    
}
