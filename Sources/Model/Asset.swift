//
//  Asset.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Foundation
import Photos

class Asset {
    
    let asset: PHAsset
    let type: MediaType
    let timeLength: String
    var isSelected: Bool = false
    
    init(asset: PHAsset, type: MediaType, timeLength: String = "") {
        self.asset = asset
        self.type = type
        self.timeLength = timeLength
    }
}

extension Asset {
    
    enum MediaType: UInt, Equatable {
        
        case photo
        case livePhoto
        case photoGif
        case video
        case auido
    }
}
