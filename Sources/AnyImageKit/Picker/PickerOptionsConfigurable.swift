//
//  PickerOptionsConfigurable.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/4.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public protocol PickerOptionsConfigurable {
    
    var childConfigurable: [PickerOptionsConfigurable] { get }
    func update(options: PickerOptionsInfo)
    func updateChildConfigurable(options: PickerOptionsInfo)
}

extension PickerOptionsConfigurable {
    
    var childConfigurable: [PickerOptionsConfigurable] {
        return []
    }
    
    func update(options: PickerOptionsInfo) {
        updateChildConfigurable(options: options)
    }
    
    func updateChildConfigurable(options: PickerOptionsInfo)  {
        for child in childConfigurable {
            child.update(options: options)
        }
    }
}
