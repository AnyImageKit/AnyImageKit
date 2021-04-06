//
//  PickerOptionsConfigurable.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/4.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

public protocol PickerOptionsConfigurable {
    
    var childrenConfigurable: [PickerOptionsConfigurable] { get }
    func update(options: PickerOptionsInfo)
    func updateChildrenConfigurable(options: PickerOptionsInfo)
}

extension PickerOptionsConfigurable {
    
    var childrenConfigurable: [PickerOptionsConfigurable] {
        return []
    }
    
    func update(options: PickerOptionsInfo) {
        updateChildrenConfigurable(options: options)
    }
    
    func updateChildrenConfigurable(options: PickerOptionsInfo)  {
        for child in childrenConfigurable {
            child.update(options: options)
        }
    }
}

extension PickerOptionsConfigurable where Self: UIViewController {
    
    var childrenConfigurable: [PickerOptionsConfigurable] {
        return suggestChildConfigurable
    }
    
    var suggestChildConfigurable: [PickerOptionsConfigurable] {
        return view.getSubviews().compactMap { $0 as? PickerOptionsConfigurable }
    }
}

extension PickerOptionsConfigurable where Self: UIView {
    
    var childrenConfigurable: [PickerOptionsConfigurable] {
        return suggestChildConfigurable
    }
    
    var suggestChildConfigurable: [PickerOptionsConfigurable] {
        return getSubviews().compactMap { $0 as? PickerOptionsConfigurable }
    }
}

extension UIView {
    
    fileprivate func getSubviews() -> [UIView] {
        if subviews.isEmpty { return [] }
        return ((subviews.flatMap { $0.getSubviews() }) + subviews)
    }
}
