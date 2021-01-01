//
//  Picker+MediaType.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/6.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Photos

extension MediaType {
    
    init(asset: PHAsset, selectOptions: PickerSelectOption) {
        let selectPhotoGIF = selectOptions.contains(.photoGIF)
        let selectPhotoLive = selectOptions.contains(.photoLive)
        
        switch asset.mediaType {
        case .image:
            if selectPhotoLive && asset.mediaSubtypes == .photoLive {
                self = .photoLive
            } else {
                if selectPhotoGIF && asset.isGIF {
                    self = .photoGIF
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
}
