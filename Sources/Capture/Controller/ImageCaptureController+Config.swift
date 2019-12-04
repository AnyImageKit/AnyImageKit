//
//  ImageCaptureController+Config.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/4.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

extension ImageCaptureController {
    
    public struct Config {
        
        /// 启用调试日志
        /// 默认：false
        public var enableDebugLog: Bool
        
        public init(enableDebugLog: Bool = false) {
            self.enableDebugLog = enableDebugLog
        }
    }
}
