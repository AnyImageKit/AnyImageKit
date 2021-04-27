//
//  Picker+MediaType.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/6.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Photos

extension MediaType {
    
    init(phAsset: PHAsset, selectOptions: PickerSelectOption) {
        switch phAsset.mediaType {
        case .image:
            if selectOptions.contains(.photoLive) && phAsset.isLivePhoto {
                self = .photoLive
            } else if selectOptions.contains(.photoGIF) && phAsset.isGIF {
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
