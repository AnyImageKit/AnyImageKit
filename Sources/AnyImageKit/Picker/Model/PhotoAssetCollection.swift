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
    /// Addition elements in asset collection
    let additionOption: AssetCollectionAdditionOption
    
    init(identifier: String, localizedTitle: String?, fetchResult: FetchResult<PHAsset>, fetchOrder: Sort, isUserLibrary: Bool, additionOption: AssetCollectionAdditionOption) {
        self.identifier = identifier
        self.localizedTitle = localizedTitle ?? identifier
        self.fetchResult = fetchResult
        self.fetchOrder = fetchOrder
        self.isUserLibrary = isUserLibrary
        self.additionOption = additionOption
    }
}

// MARK: - Sequence
extension PhotoAssetCollection: Sequence {

    func makeIterator() -> AnyIterator<PhotoAsset> {
        var count = 0
        return AnyIterator<PhotoAsset> {
            defer { count += 1 }
            if count < self.fetchResult.count {
                let phAsset = self.fetchResult[count]
                return PhotoAsset(idx: 0, phAsset: phAsset, selectOptions: .init())
            } else {
                return nil
            }
        }
    }
}

// MARK: - Collection
extension PhotoAssetCollection: Collection {

    var startIndex: Int {
        return 0
    }

    var endIndex: Int {
        return fetchResult.count
    }

    func index(after i: Int) -> Int {
        return  i + 1
    }

    subscript(position: Int) -> PhotoAsset {
        let phAsset = fetchResult[position]
        return PhotoAsset(idx: 0, phAsset: phAsset, selectOptions: .init())
    }

    subscript(bounds: IndexSet) -> [PhotoAsset] {
        return fetchResult[bounds].map {
            PhotoAsset(idx: 0, phAsset: $0, selectOptions: .init())
        }
    }
}

extension PhotoAssetCollection {

    var hasCamera: Bool {
        return additionOption.contains(.camera)
    }
}

extension PhotoAssetCollection: CustomStringConvertible {
    
    var description: String {
        return "PhotoAssetCollection<\(localizedTitle)>"
    }
}
