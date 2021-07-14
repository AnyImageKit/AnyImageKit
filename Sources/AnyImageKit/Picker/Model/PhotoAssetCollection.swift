//
//  PhotoAssetCollection.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import Foundation
import Photos

/// A wrapper for system photo smart album or user create album
struct PhotoAssetCollection: AssetCollection, IdentifiableResource {
    
    /// Unique identification
    let identifier: String
    
    /// Localized title
    let localizedTitle: String
    
    /// Fetch result from system photo library object PHAssetCollection
    let fetchResult: FetchResult<PHAsset>
    
    /// Fetch result order
    let fetchOrder: Sort
    
    /// The main user photo library flag, now it known as ‘Recent’, and in old version PhotoKit, it was called 'Camera Roll'
    let isUserLibrary: Bool
    
    /// Select Option
    let selectOption: MediaSelectOption
    
    /// Addition elements before asset collection
    let prefixAdditions: [AssetCollectionAddition]
    
    /// Addition elements after asset collection
    let suffixAdditions: [AssetCollectionAddition]
    
    /// A SHARED image STATER for all assets
    let stater: AnyImageStater<PHAsset>
    
    /// A SHARED image LOADER for all assets
    let loader: AnyImageLoader
    
    /// A SHARED image CACHER for all assets
    let cacher: AnyImageCacher
    
    init(identifier: String, localizedTitle: String?, fetchResult: FetchResult<PHAsset>, fetchOrder: Sort, isUserLibrary: Bool, selectOption: MediaSelectOption, additions: [AssetCollectionAddition], stater: AnyImageStater<PHAsset>, loader: AnyImageLoader, cacher: AnyImageCacher) {
        self.identifier = identifier
        self.localizedTitle = localizedTitle ?? String(identifier.prefix(8))
        self.fetchResult = fetchResult
        self.fetchOrder = fetchOrder
        self.isUserLibrary = isUserLibrary
        self.selectOption = selectOption
        switch fetchOrder {
        case .asc:
            self.prefixAdditions = []
            self.suffixAdditions = additions
        case .desc:
            self.prefixAdditions = additions
            self.suffixAdditions = []
        }
        self.stater = stater
        self.loader = loader
        self.cacher = cacher
    }
}

extension PhotoAssetCollection {
    
    var assetCount: Int {
        return fetchResult.count
    }
    
    subscript(asset index: Int) -> Asset<PHAsset> {
        return Asset(phAsset: fetchResult[index], selectOption: selectOption, stater: stater, loader: loader, cacher: cacher)
    }
    
    var firstAsset: Asset<PHAsset>? {
        guard let first = fetchResult.first else {
            return nil
        }
        return Asset(phAsset: first, selectOption: selectOption, stater: stater, loader: loader, cacher: cacher)
    }
    
    var lastAsset: Asset<PHAsset>? {
        guard let last = fetchResult.last else {
            return nil
        }
        return Asset(phAsset: last, selectOption: selectOption, stater: stater, loader: loader, cacher: cacher)
    }
}

// MARK: - Sequence
extension PhotoAssetCollection: Sequence {
    
    typealias Element = AssetCollectionElement<Asset<PHAsset>>

    func makeIterator() -> AnyIterator<Element> {
        var count = 0
        return AnyIterator<Element> {
            defer { count += 1 }
            switch count {
            case 0 ..< prefixCount:
                return .prefix(prefixAdditions[count])
            case prefixCount ..< (assetCount + prefixCount):
                return .asset(Asset(phAsset: fetchResult[count - prefixCount], selectOption: selectOption, stater: stater, loader: loader, cacher: cacher))
            case (assetCount + prefixCount) ..< (prefixCount + assetCount + suffixCount):
                return .suffix(suffixAdditions[count - prefixCount - assetCount])
            default:
                return nil
            }
        }
    }
}

// MARK: - Collection, BidirectionalCollection
extension PhotoAssetCollection: BidirectionalCollection {

    subscript(position: Int) -> Element {
        switch position {
        case 0 ..< prefixCount:
            return .prefix(prefixAdditions[position])
        case prefixCount ..< (assetCount + prefixCount):
            return .asset(Asset(phAsset: fetchResult[position - prefixCount], selectOption: selectOption, stater: stater, loader: loader, cacher: cacher))
        default:
            return .suffix(suffixAdditions[position - prefixCount - assetCount])
        }
    }

    subscript(bounds: IndexSet) -> [AssetCollectionElement<Asset<PHAsset>>] {
        return bounds.map { self[$0] }
    }
}

// MARK: - CustomStringConvertible
extension PhotoAssetCollection: CustomStringConvertible {
    
    var description: String {
        return "PhotoAssetCollection<\(localizedTitle)>"
    }
}
