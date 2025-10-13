//
//  SKCLayoutPlugins+herticalAlignment.swift
//  SectionUI
//
//  Created by linhey on 2024/7/25.
//

import UIKit

extension SKCLayoutPlugins {
    
    public enum HorizontalAlignment {
        case equalSpacing
    }
    
    public struct HorizontalAlignmentPayload {
        public let alignment: HorizontalAlignment
        public let sections: [SKBindingKey<Int>]
        public init(alignment: HorizontalAlignment, sections: [SKBindingKey<Int>]) {
            self.alignment = alignment
            self.sections = sections
        }
    }
    
    public struct HorizontalAlignmentPlugin: SKCLayoutPlugin {
        
        public let layoutWeakBox: SKWeakBox<SKCollectionFlowLayout>
        public let payloads: [HorizontalAlignmentPayload]
        
        public init(layout: SKCollectionFlowLayout, payloads: [HorizontalAlignmentPayload]) {
            self.layoutWeakBox = .init(layout)
            self.payloads = payloads
        }
        
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            guard scrollDirection == .vertical else {
                debugPrint("SKCLayoutPlugins.Left only support vertical scrollDirection")
                return attributes
            }
            for payload in payloads {
                run(with: attributes, payload: payload)
            }
            return attributes
        }
        
        func run(with attributes: [UICollectionViewLayoutAttributes], payload: HorizontalAlignmentPayload) {
            let (alignment, sections) = (payload.alignment, payload.sections.compactMap(\.wrappedValue))
            guard !sections.isEmpty else {
                return
            }
            
            var attributes = attributes.filter({ $0.representedElementCategory == .cell })
            if let all = SKBindingKey<Int>.all.wrappedValue, sections.contains(all) {
                
            } else {
                attributes = attributes.filter({ sections.contains($0.indexPath.section) })
            }
            
            var sectionItems = [Int: [CGFloat: [UICollectionViewLayoutAttributes]]]()
            for item in attributes {
                if sectionItems[item.indexPath.section] == nil {
                    sectionItems[item.indexPath.section] = [:]
                }
                if sectionItems[item.indexPath.section]?[item.frame.minY] == nil {
                    sectionItems[item.indexPath.section]?[item.frame.minY] = []
                }
                sectionItems[item.indexPath.section]?[item.frame.minY]?.append(item)
            }
            
           let scale = collectionView.window?.screen.scale
            
            switch alignment {
            case .equalSpacing:
                for (section, rows) in sectionItems {
                    let insets   = insetForSection(at: section)
                    for items in rows.values {
                        let allWidth = items.reduce(0) { $0 + $1.frame.width }
                        let rect     = (collectionView.bounds.width - insets.left - insets.right)
                        let spacing: CGFloat
                        
                        if let scale = scale {
                            spacing = (rect - allWidth) * scale / CGFloat(items.count - 1) / scale
                        } else {
                            spacing = floor((rect - allWidth) / CGFloat(items.count - 1))
                        }
                        var last: UICollectionViewLayoutAttributes?
                        for item in items {
                            if let last = last {
                                item.frame.origin.x = last.frame.maxX + spacing
                            } else {
                                item.frame.origin.x = insets.left
                            }
                            last = item
                        }
                    }
                }
            }
        }
    }
    
}
