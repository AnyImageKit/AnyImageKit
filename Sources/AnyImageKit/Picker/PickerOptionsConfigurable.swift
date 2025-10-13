//
//  PickerOptionsConfigurable.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/4.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

public protocol PickerOptionsConfigurable {
    
    var childrenConfigurable: [PickerOptionsConfigurable] { get }
    func update(options: PickerOptionsInfo)
    func updateChildrenConfigurable(options: PickerOptionsInfo)
}

extension PickerOptionsConfigurable {
    
    public var childrenConfigurable: [PickerOptionsConfigurable] {
        return []
    }
    
    public func update(options: PickerOptionsInfo) {
        updateChildrenConfigurable(options: options)
    }
    
    public func updateChildrenConfigurable(options: PickerOptionsInfo)  {
        for child in childrenConfigurable {
            child.update(options: options)
        }
    }
}

extension PickerOptionsConfigurable where Self: UIViewController {
    
    public var childrenConfigurable: [PickerOptionsConfigurable] {
        return preferredChildrenConfigurable
    }
    
    public var preferredChildrenConfigurable: [PickerOptionsConfigurable] {
        return view.subviews.compactMap { $0 as? PickerOptionsConfigurable }
    }
}

extension PickerOptionsConfigurable where Self: UIView {
    
    public var childrenConfigurable: [PickerOptionsConfigurable] {
        return preferredChildrenConfigurable
    }
    
    public var preferredChildrenConfigurable: [PickerOptionsConfigurable] {
        return subviews.compactMap { $0 as? PickerOptionsConfigurable }
    }
}

extension PickerOptionsConfigurable where Self: UICollectionViewCell {
    
    public var childrenConfigurable: [PickerOptionsConfigurable] {
        return preferredChildrenConfigurable
    }
    
    public var preferredChildrenConfigurable: [PickerOptionsConfigurable] {
        return contentView.subviews.compactMap { $0 as? PickerOptionsConfigurable }
    }
}

extension PickerOptionsConfigurable where Self: UITableViewCell {
    
    public var childrenConfigurable: [PickerOptionsConfigurable] {
        return preferredChildrenConfigurable
    }
    
    public var preferredChildrenConfigurable: [PickerOptionsConfigurable] {
        return contentView.subviews.compactMap { $0 as? PickerOptionsConfigurable }
    }
}
