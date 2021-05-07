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
struct PhotoAssetCollection: AssetCollection {
    
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
    
    init(identifier: String, localizedTitle: String?, fetchResult: FetchResult<PHAsset>, fetchOrder: Sort, isUserLibrary: Bool, selectOption: MediaSelectOption, additions: [AssetCollectionAddition]) {
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
    }
    
    var assetCount: Int {
        return fetchResult.count
    }
    
    func asset(at index: Int) -> Asset<PHAsset> {
        return Asset(phAsset: fetchResult[index], selectOption: selectOption)
    }
}

// MARK: - Sequence
extension PhotoAssetCollection: Sequence {

    func makeIterator() -> AnyIterator<AssetCollectionElement<Asset<PHAsset>>> {
        var count = 0
        return AnyIterator<AssetCollectionElement<Asset<PHAsset>>> {
            defer { count += 1 }
            switch count {
            case 0 ..< prefixCount:
                return .prefixAddition(prefixAdditions[count])
            case prefixCount ..< (assetCount + prefixCount):
                return .asset(Asset(phAsset: fetchResult[count - prefixCount], selectOption: selectOption))
            case (assetCount + prefixCount) ..< (prefixCount + assetCount + suffixCount):
                return .suffixAddition(suffixAdditions[count - prefixCount - assetCount])
            default:
                return nil
            }
        }
    }
}

// MARK: - Collection, BidirectionalCollection
extension PhotoAssetCollection: BidirectionalCollection {

    subscript(position: Int) -> AssetCollectionElement<Asset<PHAsset>> {
        switch position {
        case 0 ..< prefixCount:
            return .prefixAddition(prefixAdditions[position])
        case prefixCount ..< (assetCount + prefixCount):
            return .asset(Asset(phAsset: fetchResult[position - prefixCount], selectOption: selectOption))
        default:
            return .suffixAddition(suffixAdditions[position - prefixCount - assetCount])
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
