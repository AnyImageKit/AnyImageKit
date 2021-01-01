//
//  Picker+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import Photos

extension PHAsset {
    
    var isGIF: Bool {
        if let fileName = value(forKey: "filename") as? String {
            return fileName.hasSuffix("GIF")
        } else {
            return false
        }
    }
}
