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
class PhotoAssetCollection: AssetCollection {
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
    
    /// Elements in asset collection
    private(set) var assets: [Asset]
    
    init(identifier: String, localizedTitle: String?, fetchResult: FetchResult<PHAsset>, fetchOrder: Sort, isUserLibrary: Bool) {
        self.fetchResult = fetchResult
        self.identifier = identifier
        self.localizedTitle = localizedTitle ?? identifier
        self.fetchOrder = fetchOrder
        self.isUserLibrary = isUserLibrary
        self.assets = []
    }
}

extension PhotoAssetCollection {
    
    func fetchAssets(selectOptions: PickerSelectOption) {
        var array: [Asset] = []
        for phAsset in fetchResult {
            let asset = Asset(idx: array.count, asset: phAsset, selectOptions: selectOptions)
            switch asset.mediaType {
            case .photo:
                if selectOptions.contains(.photo) {
                    array.append(asset)
                }
            case .video:
                if selectOptions.contains(.video) {
                    array.append(asset)
                }
            case .photoGIF:
                if selectOptions.contains(.photoGIF) {
                    array.append(asset)
                }
            case .photoLive:
                if selectOptions.contains(.photoLive) {
                    array.append(asset)
                }
            }
        }
        assets = array
    }
}

// MARK: - Capture
extension PhotoAssetCollection {
    
    func insertAsset(_ asset: Asset, at: Int, sort: Sort) {
        assets.insert(asset, at: at)
        reloadIndex(sort: sort)
    }
    
    func addAsset(_ asset: Asset, atLast: Bool) {
        if atLast {
            assets.append(asset)
        } else {
            assets.insert(asset, at: assets.count-1)
        }
    }
    
    private func reloadIndex(sort: Sort) {
        var idx = 0
        let array: [Asset]
        switch sort {
        case .asc:
            array = Array(assets[0..<assets.count-1])
        case .desc:
            array = Array(assets[1..<assets.count])
        }
        for asset in array {
            asset.idx = idx
            idx += 1
        }
    }
}

extension PhotoAssetCollection {
    
    var count: Int {
        if hasCamera {
            return assets.count - 1
        } else {
            return assets.count
        }
    }
    
    var hasCamera: Bool {
        return (assets.first?.isCamera ?? false) || (assets.last?.isCamera ?? false)
    }
}

extension PhotoAssetCollection: CustomStringConvertible {
    
    var description: String {
        return "PhotoAssetCollection<\(localizedTitle)>"
    }
}
