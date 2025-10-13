//
//  File.swift
//
//
//  Created by linhey on 2023/10/13.
//

import UIKit

extension SKCLayoutPlugins {
    
    public enum VerticalAlignment {
        case left
        case right
        case center
    }
    
    public struct VerticalAlignmentPayload {
        public let alignment: VerticalAlignment
        public let sections: [SKBindingKey<Int>]
        
        public init(alignment: VerticalAlignment, sections: [SKBindingKey<Int>]) {
            self.alignment = alignment
            self.sections = sections
        }
    }
    
    public struct VerticalAlignmentPlugin: SKCLayoutPlugin {
        
        public let layoutWeakBox: SKWeakBox<SKCollectionFlowLayout>
        public let payloads: [VerticalAlignmentPayload]
        
        public init(layout: SKCollectionFlowLayout, payloads: [VerticalAlignmentPayload]) {
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
        
        func run(with attributes: [UICollectionViewLayoutAttributes], payload: VerticalAlignmentPayload) {
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
            
            switch alignment {
            case .left:
                for rows in sectionItems.values {
                    for items in rows.values {
                        var last: UICollectionViewLayoutAttributes?
                        for item in items {
                            if let last = last {
                                let minimumInteritemSpacing = minimumInteritemSpacing(at: item.indexPath.section)
                                item.frame.origin.x = last.frame.maxX + minimumInteritemSpacing
                            } else {
                                let insets = insetForSection(at: item.indexPath.section)
                                item.frame.origin.x = insets.left
                            }
                            last = item
                        }
                    }
                }
            case .right:
                for rows in sectionItems.values {
                    for items in rows.values {
                        var last: UICollectionViewLayoutAttributes?
                        for item in items.reversed() {
                            if let last = last {
                                let minimumInteritemSpacing = minimumInteritemSpacing(at: item.indexPath.section)
                                item.frame.origin.x = last.frame.minX - item.frame.width - minimumInteritemSpacing
                            } else {
                                let insets = insetForSection(at: item.indexPath.section)
                                item.frame.origin.x = self.collectionView.frame.width - insets.right - item.frame.width
                            }
                            last = item
                        }
                        last = nil
                    }
                }
            case .center:
                for (section, rows) in sectionItems {
                    let insets = insetForSection(at: section)
                    let spacing = minimumInteritemSpacing(at: section)
                    for items in rows.values {
                        let allWidth = items.reduce(0) { $0 + $1.frame.width } + spacing * CGFloat(items.count - 1)
                        let offset = (collectionView.bounds.width - insets.left - insets.right - allWidth) / 2 + insets.left
                        var last: UICollectionViewLayoutAttributes?
                        for item in items {
                            if let last = last {
                                item.frame.origin.x = last.frame.maxX + spacing
                            } else {
                                item.frame.origin.x = offset
                            }
                            last = item
                        }
                    }
                }
            }
        }
    }
    
}
