//
//  ImagePickerController+CaptureConfig.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/22.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

extension ImagePickerController {
    
    public struct CaptureConfig {
        
        /// Capture Media Options 拍摄类型
        /// - Default: []
        public var options: CaptureOptions
        
        /// Video maximum duration 视频最大拍摄时间，单位秒
        /// - Default: 20 seconds
        public var videoMaximumDuration: TimeInterval
        
        public init(options: CaptureOptions = [],
                    videoMaximumDuration: TimeInterval = 20) {
            self.options = options
            self.videoMaximumDuration = videoMaximumDuration
        }
    }
    
    /// Capture Options 拍摄类型
    public struct CaptureOptions: OptionSet {
        /// Photo 照片
        public static let photo = CaptureOptions(rawValue: 1 << 0)
        /// Video 视频
        public static let video = CaptureOptions(rawValue: 1 << 1)
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
