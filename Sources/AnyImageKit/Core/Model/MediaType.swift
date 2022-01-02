//
//  MediaType.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import MobileCoreServices

public enum MediaType: Equatable, CustomStringConvertible {
    
    case photo
    case video
    case photoGIF
    case photoLive
    
    init?(utType: String) {
        let kUTType = utType as CFString
        switch kUTType {
        case kUTTypeImage:
            self = .photo
        case kUTTypeMovie:
            self = .video
        case kUTTypeGIF:
            self = .photoGIF
        case kUTTypeLivePhoto:
            self = .photoLive
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .photo:
            return "PHOTO"
        case .video:
            return "VIDEO"
        case .photoGIF:
            return "PHOTO/GIF"
        case .photoLive:
            return "PHOTO/LIVE"
        }
    }
    
    public var utType: String {
        switch self {
        case .photo:
            return kUTTypeImage as String
        case .video:
            return kUTTypeMovie as String
        case .photoGIF:
            return kUTTypeGIF as String
        case .photoLive:
            return kUTTypeLivePhoto as String
        }
    }
    
    public var isImage: Bool {
        return self != .video
    }
    
    public var isVideo: Bool {
        return self == .video
    }
}
