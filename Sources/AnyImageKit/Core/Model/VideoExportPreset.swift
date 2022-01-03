//
//  VideoExportPreset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/6.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import AVFoundation
import VideoToolbox

public enum VideoExportPreset: RawRepresentable, Equatable {
    /// H.264/AVC 640x480
    case h264_640x480
    /// H.264/AVC 960x540
    case h264_960x540
    /// H.264/AVC 1280x720
    case h264_1280x720
    /// H.264/AVC 1920x1080
    case h264_1920x1080
    /// H.264/AVC 3840x2160
    case h264_3840x2160
    
    /// H.265/HEVC 1920x1080
    @available(iOS 11.0, *)
    case h265_1920x1080
    /// H.265/HEVC 3840x2160
    @available(iOS 11.0, *)
    case h265_3840x2160
    
    public var rawValue: String {
        switch self {
        case .h264_640x480:
            return AVAssetExportPreset640x480
        case .h264_960x540:
            return AVAssetExportPreset960x540
        case .h264_1280x720:
            return AVAssetExportPreset1280x720
        case .h264_1920x1080:
            return AVAssetExportPreset1920x1080
        case .h264_3840x2160:
            return AVAssetExportPreset3840x2160
        case .h265_1920x1080:
            if #available(iOS 11.0, *), VideoExportPreset.isH265ExportPresetSupported() {
                return AVAssetExportPresetHEVC1920x1080
            } else {
                return AVAssetExportPreset1920x1080
            }
        case .h265_3840x2160:
            if #available(iOS 11.0, *), VideoExportPreset.isH265ExportPresetSupported() {
                return AVAssetExportPresetHEVC3840x2160
            } else {
                return AVAssetExportPreset3840x2160
            }
        }
    }
    
    public init?(rawValue: String) {
        if #available(iOS 11.0, *) {
            switch rawValue {
            case AVAssetExportPreset640x480:
                self = .h264_640x480
            case AVAssetExportPreset960x540:
                self = .h264_960x540
            case AVAssetExportPreset1280x720:
                self = .h264_1280x720
            case AVAssetExportPreset1920x1080:
                self = .h264_1920x1080
            case AVAssetExportPreset3840x2160:
                self = .h264_3840x2160
            case AVAssetExportPresetHEVC1920x1080:
                self = .h265_1920x1080
            case AVAssetExportPresetHEVC3840x2160:
                self = .h265_3840x2160
            default:
                return nil
            }
        } else {
            switch rawValue {
            case AVAssetExportPreset640x480:
                self = .h264_640x480
            case AVAssetExportPreset960x540:
                self = .h264_960x540
            case AVAssetExportPreset1280x720:
                self = .h264_1280x720
            case AVAssetExportPreset1920x1080:
                self = .h264_1920x1080
            case AVAssetExportPreset3840x2160:
                self = .h264_3840x2160
            default:
                return nil
            }
        }
    }
}

extension VideoExportPreset {
    
    public static func isH265ExportPresetSupported() -> Bool {
        if #available(iOS 11.0, *) {
            return VTIsHardwareDecodeSupported(kCMVideoCodecType_HEVC)
        } else {
            return false
        }
    }
}
