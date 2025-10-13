//
//  File.swift
//
//
//  Created by linhey on 2024/6/12.
//

import UIKit

// MARK: - SKCLayoutPlugins Extension

public extension SKCLayoutPlugins {

    /// A struct that adjusts layout attributes.
    struct AdjustAttributesAgent: SKCLayoutPlugin {

        /// A weak reference to the layout.
        public let layoutWeakBox: SKWeakBox<SKCollectionFlowLayout>
        
        /// An array of adjustments to be applied.
        public let adjusts: [SKCPluginAdjustAttributes]

        /// Initializes a new `AdjustAttributesAgent`.
        ///
        /// - Parameters:
        ///   - layout: The layout to be adjusted.
        ///   - adjusts: An array of adjustments to be applied.
        public init(layout: SKCollectionFlowLayout, adjusts: [SKCPluginAdjustAttributes]) {
            self.layoutWeakBox = .init(layout)
            self.adjusts = adjusts
        }
        
        /// Runs the adjustments on the provided layout attributes.
        ///
        /// - Parameter attributes: The layout attributes to adjust.
        /// - Returns: The adjusted layout attributes.
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            // A dictionary to store adjustments by section.
            var store = [Int: [SKCPluginAdjustAttributes]]()
            
            // Organize adjustments by section.
            for adjust in adjusts {
                if let key = adjust.section?.wrappedValue {
                    if store[key] == nil {
                        store[key] = []
                    }
                    store[key]?.append(adjust)
                }
            }
            
            // Apply adjustments to the attributes.
            return attributes.map { attributes in
                var context = SKCPluginAdjustAttributes.Context(plugin: self, attributes: attributes)
                for adjust in store[attributes.indexPath.section] ?? [] {
                    context = adjust.style.build(context)
                }
                return attributes
            }
        }
    }
    
}
