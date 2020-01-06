//
//  MediaType.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

public enum MediaType: Equatable, CustomStringConvertible {
    
    case photo
    case video
    case photoGIF
    case photoLive
    
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
    
    public var isImage: Bool {
        return self != .video
    }
    
    public var isVideo: Bool {
        return self == .video
    }
}
