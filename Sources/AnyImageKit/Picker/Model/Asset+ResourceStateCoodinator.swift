//
//  Asset+ResourceStateCoodinator.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/25.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

extension Asset: ResourceStateCoodinator {
    
    var state: ResourceState<Resource> {
        get {
            stater.loadState(key: identifier)
        }
        nonmutating set {
            stater.updateState(newValue, key: identifier)
        }
    }
    
    var disableCheckRules: [AnyResourceDisableCheckRule<Resource>] {
        get {
            return stater.disableCheckRules
        }
        nonmutating set {
            stater.disableCheckRules = newValue
        }
    }
}
