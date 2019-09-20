//
//  Asset.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Foundation
import Photos

class Asset: Equatable {

    let idx: Int
    let asset: PHAsset
    let type: MediaType
    let timeLength: String
    var isSelected: Bool = false
    var selectedNum: Int = 1
    
    init(idx: Int, asset: PHAsset) {
        self.idx = idx
        self.asset = asset
        self.type = .photo
        self.timeLength = ""
    }
    
    static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.asset.localIdentifier == rhs.asset.localIdentifier
    }
}

extension Asset {
    
    enum MediaType: UInt, Equatable {
        
        case photo
        case livePhoto
        case photoGif
        case video
    }
}
