//
//  PhotoAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

public class PhotoAsset: Asset<PHAsset> {
    
    var _images: [ImageKey: UIImage] = [:]
    var videoDidDownload: Bool = false
}

extension PhotoAsset {
    
    /// 输出图像
    public var image: UIImage {
        return _image ?? .init()
    }
    
    var _image: UIImage? {
        return (_images[.output] ?? _images[.edited]) ?? _images[.initial]
    }
    
    var isReady: Bool {
        switch mediaType {
        case .photo, .photoGIF, .photoLive:
            return _image != nil
        case .video:
            return videoDidDownload
        }
    }
    
    var isCamera: Bool {
        return false
    }
    
    static let cameraItemIdx: Int = -1
}

extension PhotoAsset {
    
    enum ImageKey: String, Hashable {
        
        case initial
        case edited
        case output
    }
}
