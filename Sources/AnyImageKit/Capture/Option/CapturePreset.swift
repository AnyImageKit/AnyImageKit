//
//  CapturePreset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/6.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

/// The preferred presets of the camera.
public struct CapturePreset: Equatable {
    
    public let width: Int32
    public let height: Int32
    public let frameRate: Int32
}

extension CapturePreset {
    
    public static func createPresets(enableHighResolution: Bool, enableHighFrameRate: Bool) -> [CapturePreset] {
        switch (enableHighResolution, enableHighFrameRate) {
        case (true, true):
            return [.hd3840x2160_60, .hd1920x1080_60, .hd1280x720_60, .hd3840x2160_30, .hd1920x1080_30, .hd1280x720_30]
        case (true, false):
            return [.hd3840x2160_30, .hd1920x1080_30, .hd1280x720_30]
        case (false, true):
            return [.hd1920x1080_60, .hd1280x720_60, .hd1920x1080_30, .hd1280x720_30]
        case (false, false):
            return [.hd1920x1080_30, .hd1280x720_30]
        }
    }
}

extension CapturePreset {
    
    /// 3840*2160@60
    public static let hd3840x2160_60 = CapturePreset(width: 3840, height: 2160, frameRate: 60)
    /// 3840*2160@30
    public static let hd3840x2160_30 = CapturePreset(width: 3840, height: 2160, frameRate: 30)
    /// 1920x1080@60
    public static let hd1920x1080_60 = CapturePreset(width: 1920, height: 1080, frameRate: 60)
    /// 1920x1080@30
    public static let hd1920x1080_30 = CapturePreset(width: 1920, height: 1080, frameRate: 30)
    /// 1280x720@60
    public static let hd1280x720_60 = CapturePreset(width: 1280, height: 720, frameRate: 60)
    /// 1280x720@30
    public static let hd1280x720_30 = CapturePreset(width: 1280, height: 720, frameRate: 30)
}
