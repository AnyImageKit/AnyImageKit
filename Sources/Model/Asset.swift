//
//  Asset.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import Photos

public class Asset: Equatable {

    public let asset: PHAsset
    public let type: MediaType
    public internal(set) var image: UIImage = UIImage()
    
    let idx: Int
    let videoDuration: String
    var isSelected: Bool = false
    var selectedNum: Int = 1
    
    init(idx: Int, asset: PHAsset) {
        self.idx = idx
        self.asset = asset
        self.type = MediaType(asset: asset)
        self.videoDuration = asset.videoDuration
    }
    
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.asset.localIdentifier == rhs.asset.localIdentifier
    }
}

// MARK: - Original Photo

extension Asset {
    
    // TODO
}

// MARK: - Video

extension Asset {
    
    // TODO
}

