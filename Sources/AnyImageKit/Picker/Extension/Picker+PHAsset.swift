//
//  Picker+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos
import MobileCoreServices

extension PHAsset {
    
    var isVideo: Bool {
        mediaType == .video
    }
    
    var isLivePhoto: Bool {
        mediaSubtypes.contains(.photoLive)
    }
    
    var isGIF: Bool {
        playbackStyle == .imageAnimated
    }
}
