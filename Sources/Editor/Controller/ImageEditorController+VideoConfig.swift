//
//  ImageEditorController+VideoConfig.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/18.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

extension ImageEditorController {
    
    public struct VideoConfig {
        
        /// 主题色
        /// 默认：green
        public var tintColor: UIColor
        
        /// 编辑功能，会按顺序排布
        /// 默认：[.crop]
        public var editOptions: [VideoEditOption]
        
        /// 启用调试日志
        /// 默认：false
        public var enableDebugLog: Bool
        
        public init(tintColor: UIColor = Palette.main,
                    editOptions: [VideoEditOption] = [.crop],
                    enableDebugLog: Bool = false) {
            self.tintColor = tintColor
            self.editOptions = editOptions
            self.enableDebugLog = enableDebugLog
        }
    }
    
    public enum VideoEditOption {
        /// 裁剪
        case crop
    }
}
