//
//  AnyImageEvent.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/10/19.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public struct AnyImageEvent: Equatable, RawRepresentable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension AnyImageEvent: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

extension AnyImageEvent {
    
    #if ANYIMAGEKIT_ENABLE_PICKER
    public static let takePhoto: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_TAKEPHOTO"
    public static let takeVideo: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_TAKEVIDEO"
    #endif
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    public static let photoPen: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_PEN"
    public static let photoMosaic: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_MOSAIC"
    public static let photoText: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_TEXT"
    public static let photoCrop: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_CROP"
    #endif
    
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    public static let capturePhoto: AnyImageEvent = "ANYIMAGEKIT_EVENT_CAPTURE_PHOTO"
    public static let captureVideo: AnyImageEvent = "ANYIMAGEKIT_EVENT_CAPTURE_VIDEO"
    #endif
}

public struct AnyImageEventUserInfoKey: Hashable, RawRepresentable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension AnyImageEventUserInfoKey: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
