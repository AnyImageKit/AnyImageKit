//
//  Capture+AVCaptureDevice.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/19.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice {
    
    func preferredConfigs(for presets: [CapturePreset]) -> (CapturePreset, [AVCaptureDevice.Format]) {
        for preset in presets {
            let formats = preferredFormats(preset: preset, autoFocusSystem: .phaseDetection, colorSpace: .P3_D65)
            if !formats.isEmpty { return (preset, formats) }
        }
        for preset in presets {
            let formats = preferredFormats(preset: preset, autoFocusSystem: .phaseDetection, colorSpace: .sRGB)
            if !formats.isEmpty { return (preset, formats) }
        }
        for preset in presets {
            let formats = preferredFormats(preset: preset, autoFocusSystem: .contrastDetection, colorSpace: .P3_D65)
            if !formats.isEmpty { return (preset, formats) }
        }
        for preset in presets {
            let formats = preferredFormats(preset: preset, autoFocusSystem: .contrastDetection, colorSpace: .sRGB)
            if !formats.isEmpty { return (preset, formats) }
        }
        let defaultPreset: CapturePreset = .hd1280x720_30
        return (defaultPreset, preferredFormats(preset: defaultPreset, autoFocusSystem: .contrastDetection, colorSpace: .sRGB))
    }
    
    private func preferredFormats(preset: CapturePreset, autoFocusSystem: AVCaptureDevice.Format.AutoFocusSystem, colorSpace: AVCaptureColorSpace) -> [AVCaptureDevice.Format] {
        return formats.filter { format in
            let dimensions = format.formatDescription.dimensions
            if dimensions.width == preset.width && dimensions.height == preset.height {
                let ranges = format.videoSupportedFrameRateRanges.filter {
                    return $0.maxFrameRate >= Double(preset.frameRate)
                }
                return !ranges.isEmpty
            }
            return false
        }.filter { format in
            return format.autoFocusSystem == autoFocusSystem
        }.filter { format in
            return format.supportedColorSpaces.contains(colorSpace)
        }
    }
}
