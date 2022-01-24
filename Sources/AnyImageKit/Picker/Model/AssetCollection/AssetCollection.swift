//
//  AssetCollection.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/12.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

/// AssetCollection is a wapper for `AssetPlugin` and `Asset<Resource>`
public protocol AssetCollection: BidirectionalCollection, IdentifiableResource where Element == AssetCollectionElement<Asset<Resource>> {
    
    associatedtype Resource: IdentifiableResource
    
    /// Manage/Store states
    var checker: AssetChecker<Resource> { get }
    
    /// Select Option
    var selectOption: PickerSelectOption { get }
    /// Fetch result order
    var fetchOrder: Sort { get }
    
    /// Localized title for display
    var localizedTitle: String { get }
    
    /// Plugin elements before asset collection
    var prefixPlugins: [AssetPlugin] { get }
    /// Plugin elements after asset collection
    var suffixPlugins: [AssetPlugin] { get }
    
    /// Asset elements count
    var assetCount: Int { get }
    /// First asset
    var firstAsset: Asset<Resource>? { get }
    /// Last asset
    var lastAsset: Asset<Resource>? { get }
    /// Load asset index from asset
    func loadAssetIndex(for asset: Asset<Resource>) -> Int?
    /// Load asset from asset index
    func loadAsset(for assetIndex: Int) -> Asset<Resource>?
}

extension AssetCollection {
    
    /// Prefix elements count
    public var prefixCount: Int {
        return prefixPlugins.count
    }
    
    /// Suffix elements count
    public var suffixCount: Int {
        return suffixPlugins.count
    }
    
    /// Convert index to asset index
    public func convertIndexToAssetIndex(_ index: Int) -> Int {
        return index - prefixCount
    }
    
    /// Convert asset index to index
    public func convertAssetIndexToIndex(_ assetIndex: Int) -> Int {
        return assetIndex + prefixCount
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
