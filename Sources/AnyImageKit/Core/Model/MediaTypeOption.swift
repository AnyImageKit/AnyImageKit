//
//  MediaTypeOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/20.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

// MARK: - Select Options
public struct MediaTypeOption: OptionSet {
    
    /// Photo
    public static let photo = MediaTypeOption(rawValue: 1 << 0)
    
    /// Video
    public static let video = MediaTypeOption(rawValue: 1 << 1)
    
    /// GIF
    public static let photoGIF = MediaTypeOption(rawValue: 1 << 2)
    
    /// Live Photo
    public static let photoLive = MediaTypeOption(rawValue: 1 << 3)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public var isPhoto: Bool {
        return contains(.photo) || contains(.photoGIF) || contains(.photoLive)
    }
    
    public var isVideo: Bool {
        return contains(.video)
    }
}

extension MediaTypeOption {
    
    var mediaTypes: [PHAssetMediaType] {
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
