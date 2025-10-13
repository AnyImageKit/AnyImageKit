//
//  File.swift
//
//
//  Created by linhey on 2023/10/13.
//

import UIKit

public extension SKCLayoutPlugins {
    
    struct FixSupplementaryViewInset: SKCLayoutPlugin {
        
        public enum Direction: Int {
            case vertical
            case horizontal
            case all
        }
        
        public let layoutWeakBox: SKWeakBox<SKCollectionFlowLayout>
        public let direction: Direction
        
        public init(layout: SKCollectionFlowLayout, direction: Direction) {
            self.layoutWeakBox = .init(layout)
            self.direction = direction
        }
        
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            attributes
                .filter { $0.representedElementCategory == .supplementaryView }
                .forEach { attribute in
                    let inset = insetForSection(at: attribute.indexPath.section)
                    switch kind(of: attribute) {
                    case .header:
                        switch direction {
                        case .vertical:
                            attribute.frame.origin.y += inset.top
                        case .horizontal:
                            attribute.frame.origin.x += inset.left
                            attribute.frame.size.width -= (inset.left + inset.right)
                        case .all:
                            attribute.frame.origin.y += inset.top
                            attribute.frame.origin.x += inset.left
                            attribute.frame.size.width -= (inset.left + inset.right)
                        }
                    case .footer:
                        switch direction {
                        case .vertical:
                            attribute.frame.origin.y -= inset.bottom
                        case .horizontal:
                            attribute.frame.origin.x += inset.left
                            attribute.frame.size.width -= (inset.left + inset.right)
                        case .all:
                            attribute.frame.origin.y -= inset.bottom
                            attribute.frame.origin.x += inset.left
                            attribute.frame.size.width -= (inset.left + inset.right)
                        }
                    case .cell, .custom:
                        break
                    }
                }
            return attributes
        }
        
    }
    
}
