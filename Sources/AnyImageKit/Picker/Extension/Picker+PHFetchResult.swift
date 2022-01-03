//
//  Picker+PHFetchResult.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos

extension PHFetchResult where ObjectType == PHAssetCollection {
    
    func objects() -> [PHAssetCollection] {
        var results = [PHAssetCollection]()
        self.enumerateObjects { (object, index, isAtEnd) in
            results.append(object)
        }
        return results
    }
}

extension PHFetchResult where ObjectType == PHCollection {
    
    func objects() -> [PHCollection] {
        var results = [PHCollection]()
        self.enumerateObjects { (object, index, isAtEnd) in
            results.append(object)
        }
        return results
    }
}

extension PHFetchResult where ObjectType == PHAsset {
    
    func objects() -> [PHAsset] {
        var results = [PHAsset]()
        self.enumerateObjects { (object, index, isAtEnd) in
            results.append(object)
        }
        return results
    }
}
