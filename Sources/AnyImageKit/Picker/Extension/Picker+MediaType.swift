//
//  Picker+MediaType.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/6.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Photos

extension MediaType {
    
    init(asset: PHAsset, selectOptions: PickerSelectOption) {
        switch asset.mediaType {
        case .image:
            if selectOptions.contains(.photoLive) && asset.isLivePhoto {
                self = .photoLive
            } else if selectOptions.contains(.photoGIF) && asset.isGIF {
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
}
