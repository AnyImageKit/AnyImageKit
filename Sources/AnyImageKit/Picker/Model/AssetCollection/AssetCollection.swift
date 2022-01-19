//
//  AssetCollection.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/12.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public protocol AssetCollection: BidirectionalCollection {
    
    associatedtype AssetElement
    
    /// Localized title
    var localizedTitle: String { get }
    /// Addition elements before asset collection
    var prefixAdditions: [AssetCollectionAddition] { get }
    /// Addition elements after asset collection
    var suffixAdditions: [AssetCollectionAddition] { get }
    /// Prefix elements count
    var prefixCount: Int { get }
    /// Asset elements count
    var assetCount: Int { get }
    /// Suffix elements count
    var suffixCount: Int { get }
    
    subscript(asset index: Int) -> AssetElement { get }
    
    var firstAsset: AssetElement? { get }
    
    var lastAsset: AssetElement? { get }
}

extension AssetCollection {
    
    public var prefixCount: Int {
        return prefixAdditions.count
    }
    
    public var suffixCount: Int {
        return suffixAdditions.count
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
