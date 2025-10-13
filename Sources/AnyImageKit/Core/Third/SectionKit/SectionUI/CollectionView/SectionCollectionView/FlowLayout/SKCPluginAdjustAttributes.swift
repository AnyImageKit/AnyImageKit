//
//  File.swift
//
//
//  Created by linhey on 2024/6/19.
//

import Foundation
import UIKit
import SwiftUI

/// A struct that represents adjustments to be applied to layout attributes.
public struct SKCPluginAdjustAttributes {
    
    /// A context that holds the plugin and the attributes to be adjusted.
    public struct Context {
        public let plugin: SKCLayoutPlugin
        public var attributes: UICollectionViewLayoutAttributes
    }
    
    /// A typealias for a style adjustment function.
    public typealias Style = SKInout<Context>
    
    /// The section to which the adjustments apply.
    public var section: SKBindingKey<Int>?
    
    /// The style adjustments to be applied.
    public var style: Style
    
    /// Initializes a new `SKCPluginAdjustAttributes`.
    ///
    /// - Parameters:
    ///   - section: The section to which the adjustments apply.
    ///   - style: The style adjustments to be applied.
    public init(section: SKBindingKey<Int>?, _ style: Style) {
        self.style = style
        self.section = section
    }
    
}

public extension SKInout where Object == SKCPluginAdjustAttributes.Context {
    
    static func updating<Value>(_ state: Binding<Value>, from keyPath: KeyPath<Object, Value>) -> SKInout<Object> {
        .set { object in
            state.wrappedValue = object[keyPath: keyPath]
            return object
        }
    }
    
    /// Reverses the header and section inset.
    static var reverseHeaderAndSectionInset: SKInout<Object> {
        .set { context in
            guard context.attributes.representedElementCategory == .supplementaryView,
                  context.attributes.representedElementKind == UICollectionView.elementKindSectionHeader else {
                return context
            }
            let inset = context.plugin.insetForSection(at: context.attributes.indexPath.section)
            context.attributes.frame.origin.y += inset.top
            return context
        }
    }
    
    /// Reverses the footer and section inset.
    static var reverseFooterAndSectionInset: SKInout<Object> {
        .set { context in
            guard context.attributes.representedElementCategory == .supplementaryView,
                  context.attributes.representedElementKind == UICollectionView.elementKindSectionFooter else {
                return context
            }
            let inset = context.plugin.insetForSection(at: context.attributes.indexPath.section)
            context.attributes.frame.origin.y -= inset.bottom
            return context
        }
    }
    
    /// Fixes the size of supplementary views.
    static var fixSupplementaryViewSize: SKInout<Object> {
        fixFooterViewSize.set(fixHeaderViewSize)
    }
    
    static var fixFooterViewSize: SKInout<Object> {
        .set { context in
            guard context.attributes.representedElementCategory == .supplementaryView else {
                return context
            }

            let attribute = context.attributes
            switch context.plugin.kind(of: attribute) {
            case .footer:
                attribute.size = context.plugin.footerSize(at: attribute.indexPath.section)
            case .header, .cell, .custom:
                break
            }
            return context
        }
    }

    static func zIndex(when categories: [UICollectionView.ElementCategory], _ value: Int) -> SKInout<Object> {
        .set { context in
            guard categories.contains(context.attributes.representedElementCategory) else {
                return context
            }
            context.attributes.zIndex = value
            return context
        }
    }
    
    static func zIndex(when category: UICollectionView.ElementCategory, _ value: Int) -> SKInout<Object> {
        .zIndex(when: [category], value)
    }
    
    static var fixHeaderViewSize: SKInout<Object> {
        .set { context in
            guard context.attributes.representedElementCategory == .supplementaryView else {
                return context
            }

            let attribute = context.attributes
            switch context.plugin.kind(of: attribute) {
            case .header:
                attribute.size = context.plugin.headerSize(at: attribute.indexPath.section)
            case .footer, .cell, .custom:
                break
            }
            return context
        }
    }
    
}
