// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit)
import UIKit

open class SKCollectionFlowLayout: UICollectionViewFlowLayout, SKCDelegateObserverProtocol {
    
    public typealias DecorationView = UICollectionReusableView & SKLoadViewProtocol
    public typealias FixSupplementaryViewInset = SKCLayoutPlugins.FixSupplementaryViewInset.Direction
    public typealias DecorationLayout = SKCLayoutDecoration.Layout
    public typealias Decoration = SKCLayoutAnyDecoration
    public typealias BindingKey = SKBindingKey
    public typealias PluginMode = SKCLayoutPlugins.Mode
    
    class LayoutStore {
        
        lazy var cells: [IndexPath: UICollectionViewLayoutAttributes] = [:]
        lazy var decorations: [String: [IndexPath: UICollectionViewLayoutAttributes]] = [:]
        lazy var supplementaries: [String: [IndexPath: UICollectionViewLayoutAttributes]] = [:]
        
        init(attributes: [UICollectionViewLayoutAttributes]) {
            for attribute in attributes {
                store(attribute: attribute)
            }
        }
        
        func store(attribute: UICollectionViewLayoutAttributes) {
            switch attribute.representedElementCategory {
            case .cell:
                cells[attribute.indexPath] = attribute
            case .supplementaryView:
                guard let representedElementKind = attribute.representedElementKind else { return }
                if supplementaries[representedElementKind] == nil {
                    supplementaries[representedElementKind] = [attribute.indexPath: attribute]
                } else {
                    supplementaries[representedElementKind]?[attribute.indexPath] = attribute
                }
            case .decorationView:
                guard let representedElementKind = attribute.representedElementKind else { return }
                if decorations[representedElementKind] == nil {
                    decorations[representedElementKind] = [attribute.indexPath: attribute]
                } else {
                    decorations[representedElementKind]?[attribute.indexPath] = attribute
                }
            @unknown default:
                return
            }
            
        }
        
    }
    
    struct PluginsStore {
        var decorations: SKCLayoutPlugins.Decorations?
    }
    
    open override class var layoutAttributesClass: AnyClass {
        SKCLayoutAttributes.self
    }
    
    private var alwaysInvalidate: Bool?
    private lazy var oldBounds = CGRect.zero
    private var layoutTempStore: LayoutStore?
    private var layoutStore: LayoutStore = .init(attributes: [])
    private var pluginsStore: PluginsStore = .init()
    var fetchPlugins: (() -> SKCLayoutPlugins)?
    
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath, value: Void) {
        pluginsStore.decorations?.observe(kind: .willDisplay, identifier: elementKind, at: indexPath, view: view)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath, value: Void) {
        pluginsStore.decorations?.observe(kind: .didEndDisplay, identifier: elementKind, at: indexPath, view: view)
    }
    
    override public func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        layoutStore = .init(attributes: [])
        oldBounds = collectionView.bounds
    }
    
    func adjust(for rawValue: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let modes = fetchPlugins?().modes, !modes.isEmpty else { return rawValue }
        var attributes = [rawValue]
        var fixSupplementaryViewInset: SKCLayoutPlugins.FixSupplementaryViewInset?
        for mode in modes {
            switch mode {
            case .attributes(let adjusts):
                let plugin = SKCLayoutPlugins.AdjustAttributesAgent(layout: self, adjusts: adjusts)
                attributes = plugin.run(with: attributes) ?? []
            case .fixSupplementaryViewSize:
                attributes = SKCLayoutPlugins.FixSupplementaryViewSize(layout: self, condition: .excluding([])).run(with: attributes) ?? []
            case .adjustSupplementaryViewSize(let condition):
                attributes = SKCLayoutPlugins.FixSupplementaryViewSize(layout: self, condition: condition).run(with: attributes) ?? []
            case let .fixSupplementaryViewInset(direction):
                fixSupplementaryViewInset = SKCLayoutPlugins.FixSupplementaryViewInset(layout: self, direction: direction)
                attributes = fixSupplementaryViewInset?.run(with: attributes) ?? []
            default:
                break
            }
        }
        return attributes.first ?? rawValue
    }
    
    func applyMode(for attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
        guard let modes = fetchPlugins?().modes, !modes.isEmpty else { return attributes }
        var attributes = attributes
        var fixSupplementaryViewInset: SKCLayoutPlugins.FixSupplementaryViewInset?
        
        for mode in modes {
            switch mode {
            case .layoutAttributesForElements:
                break
            case .attributes(let adjusts):
                let plugin = SKCLayoutPlugins.AdjustAttributesAgent(layout: self, adjusts: adjusts)
                attributes = plugin.run(with: attributes) ?? []
            case .fixSupplementaryViewSize:
                attributes = SKCLayoutPlugins.FixSupplementaryViewSize(layout: self, condition: .excluding([])).run(with: attributes) ?? []
            case .adjustSupplementaryViewSize(let condition):
                attributes = SKCLayoutPlugins.FixSupplementaryViewSize(layout: self, condition: condition).run(with: attributes) ?? []
            case let .fixSupplementaryViewInset(direction):
                fixSupplementaryViewInset = SKCLayoutPlugins.FixSupplementaryViewInset(layout: self, direction: direction)
                attributes = fixSupplementaryViewInset?.run(with: attributes) ?? []
            case let .decorations(decorations):
                let plugin = SKCLayoutPlugins.Decorations(layout: self, decorations: decorations)
                pluginsStore.decorations = plugin
                attributes = plugin.run(with: attributes) ?? []
            case .verticalAlignment(let payload):
                attributes = SKCLayoutPlugins.VerticalAlignmentPlugin(layout: self, payloads: payload)
                    .run(with: attributes) ?? []
            case .horizontalAlignment(let payload):
                attributes = SKCLayoutPlugins.HorizontalAlignmentPlugin(layout: self, payloads: payload)
                    .run(with: attributes) ?? []
            }
            
            let context = SKCPluginLayoutAttributesForElementsForward.Context(layout: self, attributes: attributes)
            for mode in modes {
                switch mode {
                case .layoutAttributesForElements(let forwards):
                    for forward in forwards where !forward.isCanceled {
                        if context.alwaysInvalidate == true {
                            alwaysInvalidate = true
                        }
                        forward.fetch(context)
                    }
                default:
                    break
                }
            }
            
            self.alwaysInvalidate = context.alwaysInvalidate ?? false
            attributes = context.attributes
        }
        return attributes
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        defer { layoutTempStore = nil }
        guard let rawValue = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        let attributes = rawValue.compactMap { $0.copy() as? UICollectionViewLayoutAttributes }
        layoutTempStore = .init(attributes: attributes)
        pluginsStore = .init()
        return applyMode(for: attributes)
    }
    
    open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let decoration = layoutTempStore?.decorations[elementKind]?[indexPath] {
            return decoration
        } else if let decoration = layoutStore.decorations[elementKind]?[indexPath] {
            return decoration
        } else if let decoration = super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath) {
            layoutStore.store(attribute: decoration)
            return decoration
        } else {
            return nil
        }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let cell = layoutTempStore?.cells[indexPath] {
            return cell
        } else {
            return super.layoutAttributesForItem(at: indexPath)
        }
    }
    
    func attributes(of supplementary: String, at indexPath: IndexPath, useCache: Bool) -> UICollectionViewLayoutAttributes? {
        if useCache, let attributes = layoutTempStore?.supplementaries[supplementary]?[indexPath] {
            return attributes
        } else if let attributes = layoutStore.supplementaries[supplementary]?[indexPath] {
            return attributes
        } else if var attributes = super.layoutAttributesForSupplementaryView(ofKind: supplementary, at: indexPath).flatMap({ $0.copy() as? UICollectionViewLayoutAttributes }) {
            attributes = adjust(for: attributes)
            layoutStore.store(attribute: attributes)
            return attributes
        } else {
            return nil
        }
    }
    
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes(of: elementKind, at: indexPath, useCache: true)
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if oldBounds.size != newBounds.size || alwaysInvalidate == true {
            return true
        }
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
    
    open override func invalidateLayout() {
        layoutStore = .init(attributes: [])
        layoutTempStore = nil
        super.invalidateLayout()
    }
    
    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        layoutStore = .init(attributes: [])
        layoutTempStore = nil
        super.invalidateLayout(with: context)
    }
    
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        layoutStore = .init(attributes: [])
        layoutTempStore = nil
        return super.invalidationContext(forBoundsChange: newBounds)
    }
    
    open override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        layoutStore = .init(attributes: [])
        layoutTempStore = nil
        return super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
    }
    
    open override func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
        layoutStore = .init(attributes: [])
        layoutTempStore = nil
        return super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
    }
    
    open override func invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths indexPaths: [IndexPath], previousIndexPaths: [IndexPath], movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext {
        layoutStore = .init(attributes: [])
        layoutTempStore = nil
        return super.invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths: indexPaths, previousIndexPaths: previousIndexPaths, movementCancelled: movementCancelled)
    }
}
#endif
