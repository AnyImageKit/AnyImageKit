//
//  PhotoLibraryAssetCollection.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import Photos

/// A wrapper for system photo smart album or user create album
struct PhotoLibraryAssetCollection: AssetCollection, IdentifiableResource {
    
    /// Unique identification
    let identifier: String
    
    /// Localized title
    let localizedTitle: String
    
    /// Fetch result from system photo library object PHAssetCollection
    private(set) var fetchResult: FetchResult<PHAsset>
    
    /// Fetch result order
    let fetchOrder: Sort
    
    /// The main user photo library flag, now it known as ‘Recent’, and in old version PhotoKit, it was called 'Camera Roll'
    let isUserLibrary: Bool
    
    /// Select Option
    let selectOption: PickerSelectOption
    
    /// Addition elements before asset collection
    let prefixAdditions: [AssetCollectionAddition]
    
    /// Addition elements after asset collection
    let suffixAdditions: [AssetCollectionAddition]
    
    let checker: AssetChecker<PHAsset>
    
    init(identifier: String,
         localizedTitle: String?,
         fetchResult: FetchResult<PHAsset>,
         fetchOrder: Sort,
         isUserLibrary: Bool,
         selectOption: PickerSelectOption,
         additions: [AssetCollectionAddition],
         checker: AssetChecker<PHAsset>) {
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
        self.checker = checker
    }
}

extension PhotoLibraryAssetCollection {
    
    mutating func update(fetchResult: FetchResult<PHAsset>) {
        self.fetchResult = fetchResult
    }
}

extension PhotoLibraryAssetCollection {
    
    typealias AssetElement = Asset<PHAsset>
    
    var assetCount: Int {
        return fetchResult.count
    }
    
    subscript(asset index: Int) -> AssetElement {
        let asset = Asset(phAsset: fetchResult[index],
                          selectOption: selectOption,
                          checker: checker)
        checkState(asset: asset)
        return asset
    }
    
    var firstAsset: AssetElement? {
        guard let first = fetchResult.first else {
            return nil
        }
        let asset = Asset(phAsset: first,
                          selectOption: selectOption,
                          checker: checker)
        checkState(asset: asset)
        return asset
    }
    
    var lastAsset: AssetElement? {
        guard let last = fetchResult.last else {
            return nil
        }
        let asset = Asset(phAsset: last,
                          selectOption: selectOption,
                          checker: checker)
        checkState(asset: asset)
        return asset
    }
}

// MARK: - Sequence
extension PhotoLibraryAssetCollection: Sequence {
    
    typealias Element = AssetCollectionElement<AssetElement>

    func makeIterator() -> AnyIterator<Element> {
        var count = 0
        return AnyIterator<Element> {
            defer { count += 1 }
            switch count {
            case 0 ..< prefixCount:
                return .prefix(prefixAdditions[count])
            case prefixCount ..< (assetCount + prefixCount):
                let asset = Asset(phAsset: fetchResult[count - prefixCount],
                                  selectOption: selectOption,
                                  checker: checker)
                checkState(asset: asset)
                return .asset(asset)
            case (assetCount + prefixCount) ..< (prefixCount + assetCount + suffixCount):
                return .suffix(suffixAdditions[count - prefixCount - assetCount])
            default:
                return nil
            }
        }
    }
}

// MARK: - Collection, BidirectionalCollection
extension PhotoLibraryAssetCollection: BidirectionalCollection {

    subscript(position: Int) -> Element {
        switch position {
        case 0 ..< prefixCount:
            return .prefix(prefixAdditions[position])
        case prefixCount ..< (assetCount + prefixCount):
            let asset = Asset(phAsset: fetchResult[position - prefixCount],
                              selectOption: selectOption,
                              checker: checker)
            checkState(asset: asset)
            return .asset(asset)
        default:
            return .suffix(suffixAdditions[position - prefixCount - assetCount])
        }
    }

    subscript(bounds: IndexSet) -> [AssetCollectionElement<AssetElement>] {
        return bounds.map { self[$0] }
    }
}

// MARK: - CustomStringConvertible
extension PhotoLibraryAssetCollection: CustomStringConvertible {
    
    var description: String {
        return "PhotoLibraryAssetCollection<\(localizedTitle)>"
    }
}
