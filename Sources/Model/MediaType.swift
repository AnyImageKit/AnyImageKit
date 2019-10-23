//
//  MediaType.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Photos

public enum MediaType: Equatable, CustomStringConvertible {
    
    case photo
    case video
    case photoGif
    case photoLive
    
    init(asset: PHAsset, selectOptions: ImagePickerController.SelectOptions) {
        let selectPhotoLive = selectOptions.contains(.photoLive)
        
        switch asset.mediaType {
        case .image:
            if selectPhotoLive && asset.mediaSubtypes == .photoLive {
                self = .photoLive
            } else {
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
        case .video:
            return "VIDEO"
        case .photoGif:
            return "PHOTO/GIF"
        case .photoLive:
            return "PHOTO/LIVE"
        }
    }
}
