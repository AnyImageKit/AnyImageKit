//
//  MediaSelectOption.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/28.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

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
