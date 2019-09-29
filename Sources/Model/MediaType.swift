//
//  MediaType.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos

public enum MediaType: Equatable {
        
    case photo
    case photoGif
    case video
    
    init(asset: PHAsset) {
        switch asset.mediaType {
        case .image:
            if asset.isGIF {
                self = .photoGif
            } else {
                self = .photo
            }
        case .video:
            self = .video
        default:
            self = .photo
        }
    }
}
