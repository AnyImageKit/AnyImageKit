//
//  AssociatedObject.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/8/12.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import ObjectiveC

struct AssociatedObject {
    
    static func get<T>(object: Any, key: UnsafeRawPointer, defaultValue: T) -> T {
        if let value = objc_getAssociatedObject(object, key) as? T {
            return value
        } else {
            return defaultValue
        }
    }
    
    static func set<T>(object: Any, key: UnsafeRawPointer, value: T, policy: objc_AssociationPolicy) {
        objc_setAssociatedObject(object, key, value, policy)
    }
}
