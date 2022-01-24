//
//  AssetCollection.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/12.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public protocol AssetCollection: BidirectionalCollection, IdentifiableResource where Element == AssetCollectionElement<Asset<Resource>> {
    
    associatedtype Resource: IdentifiableResource
    
    /// Localized title
    var localizedTitle: String { get }
    
    /// Addition elements before asset collection
    var prefixPlugins: [AssetPlugin] { get }
    /// Addition elements after asset collection
    var suffixPlugins: [AssetPlugin] { get }
    
    /// Prefix elements count
    var prefixCount: Int { get }
    /// Asset elements count
    var assetCount: Int { get }
    /// Suffix elements count
    var suffixCount: Int { get }
    
    var selectOption: PickerSelectOption { get }
    
    var checker: AssetChecker<Resource> { get }
    
    subscript(asset index: Int) -> Asset<Resource> { get }
    
    var firstAsset: Asset<Resource>? { get }
    
    var lastAsset: Asset<Resource>? { get }
}

extension AssetCollection {
    
    public var prefixCount: Int {
        return prefixPlugins.count
    }
    
    public var suffixCount: Int {
        return suffixPlugins.count
    }
}

extension AssetCollection {
    
    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return prefixCount + assetCount + suffixCount
    }
    
    public func index(before i: Int) -> Int {
        return i - 1
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }
}
