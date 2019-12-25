//
//  ImageCaptureController+Config.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/4.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation
import AVFoundation

extension ImageCaptureController {
    
    public struct Config {
        
        public var mediaOptions: MediaOptions
        
        public var photoAspectRatio: AspectRatio
        
        public var preferredPositions: [AVCaptureDevice.Position]
        
        public var flashMode: AVCaptureDevice.FlashMode
        
        public var videoMaximumDuration: TimeInterval
        
        /// 启用调试日志
        /// 默认：false
        public var enableDebugLog: Bool
        
        public init(mediaOptions: MediaOptions = [.photo, .video],
                    photoAspectRatio: AspectRatio = .ratio4x3,
                    preferredPositions: [AVCaptureDevice.Position] = [.back, .front],
                    flashMode: AVCaptureDevice.FlashMode = .auto,
                    videoMaximumDuration: TimeInterval = 30,
                    enableDebugLog: Bool = false) {
            self.mediaOptions = mediaOptions
            self.photoAspectRatio = photoAspectRatio
            self.preferredPositions = preferredPositions
            self.flashMode = flashMode
            self.videoMaximumDuration = videoMaximumDuration
            self.enableDebugLog = enableDebugLog
        }
    }
    
    public struct MediaOptions: OptionSet {
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let photo = MediaOptions(rawValue: 1 << 0)
        
        public static let video = MediaOptions(rawValue: 1 << 1)
    }
    
    public enum AspectRatio: Equatable {
        
        case ratio1x1
        case ratio3x2
        case ratio4x3
        case ratio16x9
    }
}
