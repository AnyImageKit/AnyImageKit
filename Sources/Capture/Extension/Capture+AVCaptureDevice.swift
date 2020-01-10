//
//  Capture+AVCaptureDevice.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/19.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice {
    
    func preferredFormats(for presets: [CapturePreset]) -> (CapturePreset, [AVCaptureDevice.Format]) {
        for preset in presets {
            let formats = preferredFormats(for: preset)
            if !formats.isEmpty { return (preset, formats) }
        }
        let defaultPreset: CapturePreset = .hd1280x720_30
        return (defaultPreset, preferredFormats(for: defaultPreset))
    }
    
    private func preferredFormats(for preset: CapturePreset) -> [AVCaptureDevice.Format] {
        return formats.filter { format in
            let dimensions = format.formatDescription.dimensions
            if dimensions.width == preset.width && dimensions.height == preset.height {
                let ranges = format.videoSupportedFrameRateRanges.filter {
                    return $0.maxFrameRate >= Double(preset.frameRate)
                }
                return !ranges.isEmpty
            }
            return false
        }
    }
}
