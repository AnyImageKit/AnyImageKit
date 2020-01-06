//
//  CapturePreset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/6.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import Foundation

public struct CapturePreset: Equatable {
    
    public let width: Int32
    public let height: Int32
    public let frameRate: Int32
}

extension CapturePreset {
    
    /// 3840*2160@60
    public static let uhd3840x2160_60 = CapturePreset(width: 3840, height: 2160, frameRate: 60)
    /// 3840*2160@30
    public static let uhd3840x2160_30 = CapturePreset(width: 3840, height: 2160, frameRate: 30)
    /// 1920x1080@60
    public static let fhd1920x1080_60 = CapturePreset(width: 1920, height: 1080, frameRate: 60)
    /// 1920x1080@30
    public static let fhd1920x1080_30 = CapturePreset(width: 1920, height: 1080, frameRate: 30)
    /// 1280x720@60
    public static let hd1280x720_60 = CapturePreset(width: 1280, height: 720, frameRate: 60)
    /// 1280x720@30
    public static let hd1280x720_30 = CapturePreset(width: 1280, height: 720, frameRate: 30)
}
