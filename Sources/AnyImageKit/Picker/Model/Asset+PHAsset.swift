//
//  Asset+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/25.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Photos

extension Asset where Resource == PHAsset {
    
    public var phAsset: PHAsset {
        return resource
    }
    
    var duration: TimeInterval {
        return phAsset.duration
    }
    
    var durationDescription: String {
        let time = Int(duration)
        let min = time / 60
        let sec = time % 60
        return String(format: "%02ld:%02ld", min, sec)
    }
}
