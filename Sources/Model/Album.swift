//
//  Album.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Foundation
import Photos

class Album {
    
    let name: String
    let isCameraRoll: Bool
    let result: PHFetchResult<PHAssetCollection>
    private(set) var assets: [Asset] = []
    
    init(result: PHFetchResult<PHAssetCollection>, name: String?, isCameraRoll: Bool, needFetchAssets: Bool) {
        self.name = name ?? ""
        self.isCameraRoll = isCameraRoll
        self.result = result
        if needFetchAssets {
            fetchAssets()
        }
    }
}

extension Album {
    
    var count: Int {
        return result.count
    }
}

extension Album {
    
    func fetchAssets() {
        
    }
}
