//
//  Picker+PHAssetCollection.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos

extension PHAssetCollection {
    
    var isCameraRoll: Bool {
        return assetCollectionSubtype == .smartAlbumUserLibrary
    }
    
    var isAllHidden: Bool {
        return assetCollectionSubtype == .smartAlbumAllHidden
    }
    
    var isRecentlyDeleted: Bool {
        return assetCollectionSubtype.rawValue == 1000000201
    }
}
