//
//  MediaType.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos

public enum MediaType: Equatable, CustomStringConvertible {
    
    case photo
    case photoGif
    case video
    case photoLive
    
    init(asset: PHAsset) {
        switch asset.mediaType {
        case .image:
            switch asset.mediaSubtypes {
            case .photoLive:
                self = .photoLive
            default:
                if asset.isGIF {
                    self = .photoGif
                } else {
                    self = .photo
                }
            }
        case .video:
            self = .video
        default:
            self = .photo
        }
    }
    
    public var description: String {
        switch self {
        case .photo:
            return "PHOTO"
        case .photoGif:
            return "PHOTO/GIF"
        case .video:
            return "VIDEO"
        case .photoLive:
            return "LIVEPHOTO"
        }
    }
}
