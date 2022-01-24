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
struct PhotoLibraryAssetCollection: AssetCollection {
    
    typealias Resource = PHAsset
    
    /// Unique identification
    let identifier: String
    
    /// Localized title
    let localizedTitle: String
    
    /// Fetch result from system photo library object PHAssetCollection
    private(set) var fetchResult: FetchResult<Resource>
    
    /// Fetch result order
    let fetchOrder: Sort
    
    /// The main user photo library flag, now it known as ‘Recent’, and in old version PhotoKit, it was called 'Camera Roll'
    let isUserLibrary: Bool
    
    /// Select Option
    let selectOption: PickerSelectOption
    
    /// Addition elements before asset collection
    let prefixPlugins: [AssetPlugin]
    
    /// Addition elements after asset collection
    let suffixPlugins: [AssetPlugin]
    
    let checker: AssetChecker<Resource>
    
    init(identifier: String,
         localizedTitle: String?,
         fetchResult: FetchResult<Resource>,
         fetchOrder: Sort,
         isUserLibrary: Bool,
         selectOption: PickerSelectOption,
         plugins: [AssetPlugin],
         checker: AssetChecker<Resource>) {
        self.identifier = identifier
        self.localizedTitle = localizedTitle ?? String(identifier.prefix(8))
        self.fetchResult = fetchResult
        self.fetchOrder = fetchOrder
        self.isUserLibrary = isUserLibrary
        self.selectOption = selectOption
        switch fetchOrder {
        case .asc:
            self.prefixPlugins = []
            self.suffixPlugins = plugins
        case .desc:
            self.prefixPlugins = plugins
            self.suffixPlugins = []
        }
        self.checker = checker
    }
}

extension PhotoLibraryAssetCollection {
    
    mutating func update(fetchResult: FetchResult<Resource>) {
        self.fetchResult = fetchResult
    }
}

extension PhotoLibraryAssetCollection {
    
    var assetCount: Int {
        return fetchResult.count
    }
    
    subscript(asset index: Int) -> Asset<Resource> {
        let asset = Asset(phAsset: fetchResult[index],
                          selectOption: selectOption,
                          checker: checker)
        checkState(asset: asset)
        return asset
    }
    
    var firstAsset: Asset<Resource>? {
        guard let first = fetchResult.first else {
            return nil
        }
        let asset = Asset(phAsset: first,
                          selectOption: selectOption,
                          checker: checker)
        checkState(asset: asset)
        return asset
    }
    
    var lastAsset: Asset<Resource>? {
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

    func makeIterator() -> AnyIterator<AssetCollectionElement<Asset<Resource>>> {
        var count = 0
        return AnyIterator<Element> {
            defer { count += 1 }
            switch count {
            case 0 ..< prefixCount:
                return .prefix(prefixPlugins[count])
            case prefixCount ..< (assetCount + prefixCount):
                let asset = Asset(phAsset: fetchResult[count - prefixCount],
                                  selectOption: selectOption,
                                  checker: checker)
                checkState(asset: asset)
                return .asset(asset)
            case (assetCount + prefixCount) ..< (prefixCount + assetCount + suffixCount):
                return .suffix(suffixPlugins[count - prefixCount - assetCount])
            default:
                return nil
            }
        }
    }
}

// MARK: - Collection, BidirectionalCollection
extension PhotoLibraryAssetCollection: BidirectionalCollection {

    subscript(position: Int) -> AssetCollectionElement<Asset<Resource>> {
        switch position {
        case 0 ..< prefixCount:
            return .prefix(prefixPlugins[position])
        case prefixCount ..< (assetCount + prefixCount):
            let asset = Asset(phAsset: fetchResult[position - prefixCount],
                              selectOption: selectOption,
                              checker: checker)
            checkState(asset: asset)
            return .asset(asset)
        default:
            return .suffix(suffixPlugins[position - prefixCount - assetCount])
        }
    }

    subscript(bounds: IndexSet) -> [AssetCollectionElement<Asset<Resource>>] {
        return bounds.map { self[$0] }
    }
}

// MARK: - CustomStringConvertible
extension PhotoLibraryAssetCollection: CustomStringConvertible {
    
    var description: String {
        return "PhotoLibraryAssetCollection<\(localizedTitle)>"
    }
}
