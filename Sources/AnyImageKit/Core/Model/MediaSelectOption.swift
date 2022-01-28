//
//  MediaSelectOption.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/28.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import Photos

public struct MediaSelectOption: OptionSet {
    
    /// Photo
    public static let photo = MediaSelectOption(rawValue: 1 << 0)
    /// Video
    public static let video = MediaSelectOption(rawValue: 1 << 1)
    /// GIF
    public static let photoGIF = MediaSelectOption(rawValue: 1 << 2)
    /// Live Photo
    public static let photoLive = MediaSelectOption(rawValue: 1 << 3)
    
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

extension MediaSelectOption {
    
    var predicate: NSPredicate? {
        switch self {
        case [.photo, .video], [.photo, .photoGIF, .video], [.photo, .photoLive, .video], [.photo, .photoGIF, .photoLive, .video]:
            return nil
        case [.photo], [.photo, .photoGIF], [.photo, .photoLive], [.photo, .photoGIF, .photoLive]:
            return NSPredicate(format: "%K == %ld", #keyPath(PHAsset.mediaType), PHAssetMediaType.image.rawValue)
        case [.video]:
            return NSPredicate(format: "%K == %ld", #keyPath(PHAsset.mediaType), PHAssetMediaType.video.rawValue)
        case [.photoGIF]:
            return NSPredicate(format: "%K == %ld", #keyPath(PHAsset.playbackStyle), PHAsset.PlaybackStyle.imageAnimated.rawValue)
        case [.photoLive]:
            return NSPredicate(format: "%K == %ld", #keyPath(PHAsset.mediaSubtypes), PHAssetMediaSubtype.photoLive.rawValue)
        case [.photoGIF, .photoLive]:
            let predicates = [NSPredicate(format: "%K == %ld", #keyPath(PHAsset.playbackStyle), PHAsset.PlaybackStyle.imageAnimated.rawValue),
                              NSPredicate(format: "%K == %ld", #keyPath(PHAsset.mediaSubtypes), PHAssetMediaSubtype.photoLive.rawValue)]
            return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        default:
            return nil
        }
    }
}

