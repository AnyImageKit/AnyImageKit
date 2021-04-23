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
    private(set) var elements: [PhotoAsset]
    /// Addition elements in asset collection
    let additionOption: AssetCollectionAdditionOption
    
    init(identifier: String, localizedTitle: String?, fetchResult: FetchResult<PHAsset>, fetchOrder: Sort, isUserLibrary: Bool, additionOption: AssetCollectionAdditionOption) {
        self.identifier = identifier
        self.localizedTitle = localizedTitle ?? identifier
        self.fetchResult = fetchResult
        self.fetchOrder = fetchOrder
        self.isUserLibrary = isUserLibrary
        self.elements = []
        self.additionOption = additionOption
    }
}

extension PhotoAssetCollection {
    
    func fetchAssets(selectOptions: PickerSelectOption) {
        var array: [PhotoAsset] = []
        
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        if additionOption.contains(.camera), fetchOrder == .desc {
            array.append(PhotoAsset(idx: PhotoAsset.cameraItemIdx, asset: .init(), selectOptions: selectOptions))
        }
        #endif
        
        for phAsset in fetchResult {
            let asset = PhotoAsset(idx: array.count, asset: phAsset, selectOptions: selectOptions)
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
        
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        if additionOption.contains(.camera), fetchOrder == .asc {
            array.append(PhotoAsset(idx: PhotoAsset.cameraItemIdx, asset: .init(), selectOptions: selectOptions))
        }
        #endif
        
        elements = array
    }
}

extension PhotoAssetCollection {
    
    var count: Int {
        if hasCamera {
            return elements.count - 1
        } else {
            return elements.count
        }
    }
    
    var hasCamera: Bool {
        return additionOption.contains(.camera)
    }
}

extension PhotoAssetCollection: CustomStringConvertible {
    
    var description: String {
        return "PhotoAssetCollection<\(localizedTitle)>"
    }
}
