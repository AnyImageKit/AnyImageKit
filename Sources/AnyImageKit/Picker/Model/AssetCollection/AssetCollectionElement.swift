//
//  AssetCollectionElement.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/5/6.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public enum AssetCollectionElement<Element: IdentifiableResource>: Equatable {
    
    case prefix(AssetPlugin)
    case asset(Element)
    case suffix(AssetPlugin)
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
    
    public var plugin: AssetPlugin? {
        switch self {
        case .prefix(let plugin), .suffix(let plugin):
            return plugin
        default:
            return nil
        }
    }
    
    public var prefix: AssetPlugin? {
        switch self {
        case .prefix(let plugin):
            return plugin
        default:
            return nil
        }
    }
    
    public var suffix: AssetPlugin? {
        switch self {
        case .suffix(let plugin):
            return plugin
        default:
            return nil
        }
    }
}
