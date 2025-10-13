//
//  File.swift
//  
//
//  Created by linhey on 2023/10/13.
//

import UIKit

extension SKCLayoutPlugins {
    
    struct SectionHeadersPinToVisibleBounds: SKCLayoutPlugin {
        let layoutWeakBox: SKWeakBox<SKCollectionFlowLayout>
        var elements: [SKBindingKey<Int>]
        var sectionRects: [Int: CGRect]
        
        init(layout: SKCollectionFlowLayout, 
             elements: [SKBindingKey<Int>],
             sectionRects: [Int : CGRect] = [:]) {
            self.layoutWeakBox = .init(layout)
            self.elements = elements
            self.sectionRects = sectionRects
        }
        
        mutating func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            attributes
                .filter { attribute in
                    switch attribute.representedElementCategory {
                    case .supplementaryView:
                        return true
                    case .cell:
                        return true
                    case .decorationView:
                        return false
                    @unknown default:
                        return false
                    }
                }
                .forEach { attribute in
                    if let rect = sectionRects[attribute.indexPath.section] {
                        sectionRects[attribute.indexPath.section] = rect.union(attribute.frame)
                    } else {
                        sectionRects[attribute.indexPath.section] = attribute.frame
                    }
                }
            return attributes
        }
        
        func invalidationContext(context: UICollectionViewLayoutInvalidationContext, forBoundsChange newBounds: CGRect) {
            guard let layout else { return }
            if layout.sectionHeadersPinToVisibleBounds {
                assertionFailure("sectionHeadersPinToVisibleBounds == true 与 pluginMode.sectionHeadersPinToVisibleBounds 冲突")
            }
            let indexPaths = elements
                .compactMap(\.wrappedValue)
                .filter { index in
                    sectionRects[index]?.intersects(newBounds) ?? true
                }
                .map { IndexPath(row: 0, section: $0) }
            context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader, at: indexPaths)
        }
        
        func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                  at indexPath: IndexPath,
                                                  with attributes: UICollectionViewLayoutAttributes) {
            guard attributes.representedElementKind == UICollectionView.elementKindSectionHeader,
                  elements.compactMap(\.wrappedValue).contains(attributes.indexPath.section),
                  let rect = sectionRects[indexPath.section] else {
                return
            }
            attributes.zIndex += attributes.indexPath.section
            if collectionView.contentOffset.y >= rect.minY, collectionView.contentOffset.y <= rect.maxY {
                if collectionView.contentOffset.y + attributes.frame.height >= rect.maxY {
                    attributes.frame.origin.y = rect.maxY - attributes.frame.height
                } else {
                    attributes.frame.origin.y = collectionView.contentOffset.y
                }
            }
        }
        
    }
    
}
