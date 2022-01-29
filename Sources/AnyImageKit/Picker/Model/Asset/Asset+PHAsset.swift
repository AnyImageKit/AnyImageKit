//
//  Asset+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/23.
//  Copyright © 2021-2022 AnyImageProject.org. All rights reserved.
//

import Foundation
import Photos
import UIKit

extension Asset where Resource == PHAsset {
    
    init(phAsset: PHAsset, selectOption: MediaSelectOption, checker: AssetChecker<PHAsset>) {
        if selectOption.contains(.video), phAsset.isVideo {
            self.init(resource: phAsset, mediaType: .video, checker: checker)
        } else if selectOption.contains(.photoLive), phAsset.isLivePhoto {
            self.init(resource: phAsset, mediaType: .photoLive, checker: checker)
        } else if selectOption.contains(.photoGIF), phAsset.isGIF {
            self.init(resource: phAsset, mediaType: .photoGIF, checker: checker)
        } else {
            self.init(resource: phAsset, mediaType: .photo, checker: checker)
        }
    }
    
    var phAsset: PHAsset {
        return resource
    }
}

extension Asset where Resource == PHAsset {
    
    var duration: TimeInterval {
        return phAsset.duration
    }
    
    var image: UIImage {
        return UIImage()
    }
    
    var durationDescription: String {
        let time = Int(duration)
        let min = time / 60
        let sec = time % 60
        return String(format: "%02ld:%02ld", min, sec)
    }
    
    var isReady: Bool {
        return true
    }
}
