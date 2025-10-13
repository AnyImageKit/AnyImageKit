//
//  MyCustomLayoutAttributes.swift
//  Pods
//
//  Created by linhey on 5/14/25.
//

import UIKit

class SKCLayoutAttributes: UICollectionViewLayoutAttributes {
    
    override func copy(with zone: NSZone? = nil) -> Any {
        guard let copiedAttributes = super.copy(with: zone) as? SKCLayoutAttributes else {
            return super.copy(with: zone)
        }
        return copiedAttributes
    }

}
