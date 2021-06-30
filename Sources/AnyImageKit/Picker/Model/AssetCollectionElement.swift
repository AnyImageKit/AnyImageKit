//
//  AssetCollectionElement.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/5/6.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public enum AssetCollectionElement<Element: IdentifiableResource>: Equatable {
    
    case prefix(AssetCollectionAddition)
    case asset(Element)
    case suffix(AssetCollectionAddition)
}

extension AssetCollectionElement {
    
    public var asset: Element? {
        switch self {
        case .asset(let asset):
            return asset
        default:
            return nil
        }
    }
}

extension AssetCollectionElement {
    
    public var addition: AssetCollectionAddition? {
        switch self {
        case .prefix(let addition), .suffix(let addition):
            return addition
        default:
            return nil
        }
    }
    
    public var prefix: AssetCollectionAddition? {
        switch self {
        case .prefix(let addition):
            return addition
        default:
            return nil
        }
    }
    
    public var suffix: AssetCollectionAddition? {
        switch self {
        case .suffix(let addition):
            return addition
        default:
            return nil
        }
    }
}
