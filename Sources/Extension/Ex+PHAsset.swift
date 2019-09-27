//
//  Ex+PHAsset.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos
import MobileCoreServices

extension PHAsset {
    
    var isGIF: Bool {
        if let fileName = value(forKey: "filename") as? String {
            return fileName.hasSuffix("GIF")
        } else {
            return false
        }
    }
    
    var videoDuration: String {
        guard mediaType == .video else { return "" }
        let time = Int(duration)
        let min = time / 60
        let sec = time % 60
        return String(format: "%02ld:%02ld", min, sec)
    }
}
