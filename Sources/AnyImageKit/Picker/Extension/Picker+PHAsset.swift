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
    
    var isLivePhoto: Bool {
        return mediaSubtypes.contains(.photoLive)
    }
    
    @objc var isGIF: Bool {
        if let dataUTI = value(forKey: "uniformTypeIdentifier") as? String {
            return UTTypeConformsTo(dataUTI as CFString, kUTTypeGIF)
        }
        return false
    }
}
