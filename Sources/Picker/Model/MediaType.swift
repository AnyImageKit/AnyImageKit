//
//  MediaType.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Photos

public enum MediaType: Equatable, CustomStringConvertible {
    
    case photo
    case video
    case photoGIF
    case photoLive
    
    init(asset: PHAsset, selectOptions: ImagePickerController.SelectOptions) {
        let selectPhotoGIF = selectOptions.contains(.photoGIF)
        let selectPhotoLive = selectOptions.contains(.photoLive)
        
        switch asset.mediaType {
        case .image:
            
            if #available(iOS 9.1, *) {
                if selectPhotoLive && asset.mediaSubtypes == .photoLive {
                    self = .photoLive
                } else if selectPhotoGIF && asset.isGIF {
                    self = .photoGIF
                } else {
                    self = .photo
                }
            } else if selectPhotoGIF && asset.isGIF {
                self = .photoGIF
            } else {
                self = .photo
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
        case .photoGIF:
            return "PHOTO/GIF"
        case .photoLive:
            return "PHOTO/LIVE"
        }
    }
    
    public var isImage: Bool {
        return self != .video
    }
    
    public var isVideo: Bool {
        return self == .video
    }
}
