//
//  BrowserOptionsConfigurable.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/13.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit

public protocol BrowserOptionsConfigurable {
    var childrenConfigurable: [BrowserOptionsConfigurable] { get }
    func update(options: BrowserOptionsInfo)
    func updateChildrenConfigurable(options: BrowserOptionsInfo)
}

extension BrowserOptionsConfigurable {
    
    public var childrenConfigurable: [BrowserOptionsConfigurable] {
        return []
    }
    
    public func update(options: BrowserOptionsInfo) {
        updateChildrenConfigurable(options: options)
    }
    
    public func updateChildrenConfigurable(options: BrowserOptionsInfo)  {
        for child in childrenConfigurable {
            child.update(options: options)
        }
    }
}

extension BrowserOptionsConfigurable where Self: UIViewController {
    
    public var childrenConfigurable: [BrowserOptionsConfigurable] {
        return preferredChildrenConfigurable
    }
    
    public var preferredChildrenConfigurable: [BrowserOptionsConfigurable] {
        return view.subviews.compactMap { $0 as? BrowserOptionsConfigurable }
    }
}

extension BrowserOptionsConfigurable where Self: UIView {
    
    public var childrenConfigurable: [BrowserOptionsConfigurable] {
        return preferredChildrenConfigurable
    }
    
    public var preferredChildrenConfigurable: [BrowserOptionsConfigurable] {
        return subviews.compactMap { $0 as? BrowserOptionsConfigurable }
    }
}

extension BrowserOptionsConfigurable where Self: UICollectionViewCell {
    
    public var childrenConfigurable: [BrowserOptionsConfigurable] {
        return preferredChildrenConfigurable
    }
    
    public var preferredChildrenConfigurable: [BrowserOptionsConfigurable] {
        return contentView.subviews.compactMap { $0 as? BrowserOptionsConfigurable }
    }
}

extension BrowserOptionsConfigurable where Self: UITableViewCell {
    
    public var childrenConfigurable: [BrowserOptionsConfigurable] {
        return preferredChildrenConfigurable
    }
    
    public var preferredChildrenConfigurable: [BrowserOptionsConfigurable] {
        return contentView.subviews.compactMap { $0 as? BrowserOptionsConfigurable }
    }
}
