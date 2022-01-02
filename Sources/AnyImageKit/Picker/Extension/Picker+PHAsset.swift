//
//  Picker+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos

extension PHAsset {
    
    var isLivePhoto: Bool {
        return mediaSubtypes.contains(.photoLive)
    }
    
    var isGIF: Bool {
        if let fileName = value(forKey: "filename") as? String {
            return fileName.uppercased().hasSuffix("GIF")
        } else {
            return false
        }
    }
}
