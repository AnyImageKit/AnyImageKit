//
//  File.swift
//  
//
//  Created by linhey on 2023/10/13.
//

import UIKit

extension SKCLayoutPlugins {
    
    public struct FixSupplementaryViewSize: SKCLayoutPlugin {
        
        public enum Condition {
            case excluding([Constraint])
            case including([Constraint])
        }
        
        public struct Constraint {
            public let section: SKBindingKey<Int>
            public let kind: SKSupplementaryKind
            public let insets: UIEdgeInsets
            
            public init(section: SKBindingKey<Int>, kind: SKSupplementaryKind, insets: UIEdgeInsets = .zero) {
                self.section = section
                self.kind = kind
                self.insets = insets
            }
            
            public init(section: SKCSectionProtocol, kind: SKSupplementaryKind, insets: UIEdgeInsets = .zero) {
                self.section = .init(section)
                self.kind = kind
                self.insets = insets
            }
        }
        
        public let layoutWeakBox: SKWeakBox<SKCollectionFlowLayout>
        public let condition: Condition
        
        public init(layout: SKCollectionFlowLayout, condition: Condition) {
            self.layoutWeakBox = .init(layout)
            self.condition = condition
        }
        
        func constraint(of index: Int, kind: SKSupplementaryKind) -> Constraint? {
            switch condition {
            case .excluding(let array):
                return array.contains(where: { $0.section.wrappedValue == index && $0.kind == kind }) ? nil : .init(section: .init(get: { index }), kind: kind)
            case .including(let array):
                return array.first(where: { $0.section.wrappedValue == index && $0.kind == kind })
            }
        }
        
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            attributes
                .filter { $0.representedElementCategory == .supplementaryView }
                .forEach { attribute in
                    switch kind(of: attribute) {
                    case .header:
                        if let constraint = constraint(of: attribute.indexPath.section, kind: .header) {
                            attribute.size = self.headerSize(at: attribute.indexPath.section)
                            attribute.frame = attribute.frame.apply(insets: constraint.insets)
                        }
                    case .footer:
                        if let constraint = constraint(of: attribute.indexPath.section, kind: .footer) {
                            attribute.size = self.footerSize(at: attribute.indexPath.section)
                            attribute.frame = attribute.frame.apply(insets: constraint.insets)
                        }
                    case .cell, .custom:
                        break
                    }
                }
            return attributes
        }
        
    }
    
}


