//
//  SKCSectionPin.swift
//  Pods
//
//  Created by linhey on 5/28/25.
//

import UIKit
import Combine

public class SKCSectionPinOptions {
    
    public typealias Builder = (_ options: inout SKCSectionPinOptions) -> Void
    public typealias AttributesAdjust = (_ options: SKCSectionPinOptions, _ attributes: UICollectionViewLayoutAttributes) -> Void
    public var id: String = UUID().uuidString
    public let kind: SKSupplementaryKind
    public var row: Int
    public let section: SKBindingKey<Int?>
    /// 距离顶部间距
    public var padding: CGFloat = 0
    /// 是否启用
    public var isEnabled: Bool = true
    /// 自定义修改 UICollectionViewLayoutAttributes, 可以用来实现高度动画
    public private(set) var customAdjust: AttributesAdjust?
    /// 距离目标位置距离监听
    @SKPublished public var distance: CGFloat?
    /// 是否到达目标位置监听
    @SKPublished(transform: .removeDuplicates()) public var isPinned: Bool = false

    public init(kind: SKSupplementaryKind,
                row: Int = 0,
                section: SKBindingKey<Int?>,
                id: String = UUID().uuidString) {
        self.id = id
        self.kind = kind
        self.row = row
        self.section = section
    }
    
    public func set(_ block: (_ pin: SKCSectionPinOptions) -> Void) -> Self {
        block(self)
        return self
    }
    
    public func customAdjust(_ adjust: AttributesAdjust?) -> Self {
        self.customAdjust = adjust
        return self
    }
}

public extension SKCSectionLayoutPluginProtocol {
    
    @discardableResult
    func pinHeader(options: SKCSectionPinOptions.Builder? = nil) -> AnyCancellable {
        var item = SKCSectionPinOptions(kind: .header, row: 0, section: .init(get: { [weak self] in
            guard let self = self else { return 0 }
            return sectionInjection?.index
        }))
        options?(&item)
        return pin(options: item)
    }
    
    @discardableResult
    func pinFooter(options: SKCSectionPinOptions.Builder? = nil) -> AnyCancellable {
        var item = SKCSectionPinOptions(kind: .footer, row: 0, section: .init(get: { [weak self] in
            guard let self = self else { return 0 }
            return sectionInjection?.index ?? 0
        }))
        options?(&item)
        return pin(options: item)
    }
    
    @discardableResult
    func pinCell(at row: Int, options: SKCSectionPinOptions.Builder? = nil) -> AnyCancellable {
        var item = SKCSectionPinOptions(kind: .cell, row: row, section: .init(get: { [weak self] in
            guard let self = self else { return 0 }
            return sectionInjection?.index ?? 0
        }))
        options?(&item)
        return pin(options: item)
    }
    
}

public extension SKCSectionLayoutPluginProtocol {
    
    @discardableResult
    @available(*, deprecated, renamed: "pinHeader", message: "manager not required.")
    func pin(header manager: SKCManager) -> AnyCancellable {
        return pinHeader()
    }
    
    @discardableResult
    @available(*, deprecated, renamed: "pinFooter", message: "manager not required.")
    func pin(footer manager: SKCManager) -> AnyCancellable {
        return pinFooter()
    }
    
    @discardableResult
    @available(*, deprecated, renamed: "pinCell", message: "manager not required.")
    func pin(cell row: Int, manager: SKCManager) -> AnyCancellable {
        return pinCell(at: row)
    }
    
}

public extension SKCSectionLayoutPluginProtocol where Self: SKCSectionProtocol {
    
    @discardableResult
    func pin(options: SKCSectionPinOptions) -> AnyCancellable {
        let forward = SKCPluginLayoutAttributesForElementsForward(userInfo: ["options": options]) { [weak options] context in
            
            guard let options = options,
                  let sectionView = context.layout.collectionView,
                  let maxSection = context.attributes.map(\.indexPath.section).max()else {
                return
            }
            
            guard let sectionWrappedValue = options.section.wrappedValue,
                  let section = sectionWrappedValue,
                  maxSection >= section else {
                options.isPinned = false
                options.distance = nil
                return
            }
            
            #if DEBUG
            if let layout = sectionView.collectionViewLayout as? UICollectionViewFlowLayout,
               layout.sectionHeadersPinToVisibleBounds == true || layout.sectionFootersPinToVisibleBounds == true {
                assertionFailure("SKCSectionPinOptions is not compatible with UICollectionViewFlowLayout's pinning feature. Please disable pinning in UICollectionViewFlowLayout.")
            }
            #endif
            
            var maxZIndex = 0
            var stickyAttribute: UICollectionViewLayoutAttributes?
            func sticky(attribute: UICollectionViewLayoutAttributes) {
                let distance = attribute.frame.origin.y - (contentOffset.y + options.padding)
                context.alwaysInvalidate = true
                if 0 >= distance, options.isEnabled {
                    attribute.frame.origin.y = contentOffset.y + options.padding
                    options.isPinned = true
                    options.distance = 0
                } else {
                    options.isPinned = false
                    options.distance = distance
                }
                options.customAdjust?(options, attribute)
            }
            
            var isFinded = false
            let contentOffset = sectionView.contentOffset
            
            for attribute in context.attributes {
                guard attribute.indexPath.section == section else {
                    maxZIndex = max(attribute.zIndex, maxZIndex)
                    continue
                }
                switch attribute.representedElementCategory {
                case .supplementaryView:
                    if let representedElementKind = attribute.representedElementKind,
                       SKSupplementaryKind(rawValue: representedElementKind) == options.kind {
                        sticky(attribute: attribute)
                        if options.isEnabled {
                            stickyAttribute = attribute
                        }
                        isFinded = true
                    } else {
                        maxZIndex = max(attribute.zIndex, maxZIndex)
                    }
                case .decorationView:
                    break
                case .cell:
                    if attribute.representedElementCategory == .cell, attribute.indexPath.row == options.row {
                        sticky(attribute: attribute)
                        if options.isEnabled {
                            stickyAttribute = attribute
                        }
                        isFinded = true
                    } else {
                        maxZIndex = max(attribute.zIndex, maxZIndex)
                    }
                @unknown default:
                    break
                }
            }
            
            if !isFinded {
                switch options.kind {
                case .header, .footer:
                    if let attribute = context.layout.layoutAttributesForSupplementaryView(ofKind: options.kind.rawValue,
                                                                                           at: .init(row: options.row,
                                                                                                     section: section)) {
                        sticky(attribute: attribute)
                        if options.isEnabled {
                            stickyAttribute = attribute
                            context.attributes.append(attribute)
                        }
                    }
                case .cell:
                    if let attribute = context.layout.layoutAttributesForItem(at: .init(row: options.row, section: section)) {
                        sticky(attribute: attribute)
                        if options.isEnabled {
                            stickyAttribute = attribute
                            context.attributes.append(attribute)
                        }
                    }
                case .custom:
                    break
                }
            }
            
            stickyAttribute?.zIndex = maxZIndex + 1
        }
    
        self.addLayoutPlugins(.layoutAttributesForElements(forward))
        return .init(forward)
    }
    
}
