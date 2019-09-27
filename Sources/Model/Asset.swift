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
        self.type = MediaType(asset: asset)
        self.timeLength = asset.videoDuration
    }
    
    static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.asset.localIdentifier == rhs.asset.localIdentifier
    }
}

extension Asset {
    
    enum MediaType: UInt, Equatable {
        
        case photo
        case photoLive
        case photoGif
        case video
        case audio
        
        init(asset: PHAsset) {
            switch asset.mediaType {
            case .image:
//                if asset.mediaSubtypes == .photoLive { // not support live photo
//                    self = .photoLive
//                }
                if let fileName = asset.value(forKey: "filename") as? String, fileName.hasSuffix("GIF") {
                    self = .photoGif
                } else {
                    self = .photo
                }
            case .video:
                self = .video
            case .audio:
                self = .audio
            default:
                self = .photo
            }
        }
    }
}

extension PHAsset {
    
    var videoDuration: String {
        guard mediaType == .video else { return "" }
        let time = Int(duration)
        let min = time / 60
        let sec = time % 60
        return String(format: "%02ld:%02ld", min, sec)
    }
    
}
