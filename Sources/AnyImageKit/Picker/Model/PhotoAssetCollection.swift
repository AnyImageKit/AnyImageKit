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
    
    /// Addition elements in asset collection
    let additionOption: AssetCollectionAdditionOption
    
    init(identifier: String, localizedTitle: String?, fetchResult: FetchResult<PHAsset>, fetchOrder: Sort, isUserLibrary: Bool, selectOption: MediaSelectOption, additionOption: AssetCollectionAdditionOption) {
        self.identifier = identifier
        self.localizedTitle = localizedTitle ?? String(identifier.prefix(8))
        self.fetchResult = fetchResult
        self.fetchOrder = fetchOrder
        self.isUserLibrary = isUserLibrary
        self.selectOption = selectOption
        self.additionOption = additionOption
    }
}

// MARK: - Sequence
extension PhotoAssetCollection: Sequence {

    func makeIterator() -> AnyIterator<Asset<PHAsset>> {
        var count = 0
        return AnyIterator<Asset<PHAsset>> {
            defer { count += 1 }
            if count < self.fetchResult.count {
                let phAsset = self.fetchResult[count]
                return Asset(phAsset: phAsset, selectOption: selectOption)
            } else {
                return nil
            }
        }
    }
}

// MARK: - Collection
extension PhotoAssetCollection: Collection, BidirectionalCollection {

    var startIndex: Int {
        return 0
    }

    var endIndex: Int {
        return fetchResult.count
    }
    
    func index(before i: Int) -> Int {
        return i - 1
    }

    func index(after i: Int) -> Int {
        return i + 1
    }

    subscript(position: Int) -> Asset<PHAsset> {
        let phAsset = fetchResult[position]
        return Asset(phAsset: phAsset, selectOption: selectOption)
    }

    subscript(bounds: IndexSet) -> [Asset<PHAsset>] {
        return fetchResult[bounds].map {
            Asset(phAsset: $0, selectOption: selectOption)
        }
    }
}

extension PhotoAssetCollection: CustomStringConvertible {
    
    var description: String {
        return "PhotoAssetCollection<\(localizedTitle)>"
    }
}
