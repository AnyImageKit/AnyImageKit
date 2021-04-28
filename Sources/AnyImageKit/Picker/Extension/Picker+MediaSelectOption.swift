//
//  Picker+MediaSelectOption.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/28.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Photos

extension MediaSelectOption {
    
    var phAssetMediaTypes: [PHAssetMediaType] {
        var result: [PHAssetMediaType] = []
        if contains(.photo) || contains(.photoGIF) || contains(.photoLive) {
            result.append(.image)
        }
        if contains(.video) {
            result.append(.video)
        }
        return result
    }
}
