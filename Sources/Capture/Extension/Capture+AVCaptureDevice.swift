//
//  Capture+AVCaptureDevice.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/19.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice {
    
    func preferredFormats(for presets: [Preset]) -> [AVCaptureDevice.Format] {
        for preset in presets {
            let formats = preferredFormats(for: preset)
            if !formats.isEmpty { return formats }
        }
        return []
    }
    
    private func preferredFormats(for preset: Preset) -> [AVCaptureDevice.Format] {
        return formats.filter { format in
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            if dimensions.width == preset.width && dimensions.height == preset.height {
                let ranges = format.videoSupportedFrameRateRanges.filter {
                    return $0.maxFrameRate >= 60
                }
                return !ranges.isEmpty
            }
            return false
        }
    }
}

extension AVCaptureDevice {
    
    struct Preset: Equatable {
        
        let width: Int32
        let height: Int32
        let fps: Double
        
        static let preferred: [Preset] = [
            Preset(width: 3840, height: 2160, fps: 60.0),
            Preset(width: 3840, height: 2160, fps: 30.0),
            Preset(width: 1920, height: 1080, fps: 60.0),
            Preset(width: 1920, height: 1080, fps: 30.0),
            Preset(width: 1280, height: 720, fps: 60.0),
            Preset(width: 1280, height: 720, fps: 30.0),
        ]
    }
}
