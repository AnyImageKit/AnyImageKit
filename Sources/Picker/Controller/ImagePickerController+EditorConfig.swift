//
//  ImagePickerController+EditorConfig.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/20.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

#if ANYIMAGEKIT_ENABLE_EDITOR

extension ImagePickerController {
    
    public struct EditorConfig {
        /// Options 编辑类型
        /// - Default: []
        public var options: EditorOptions
        
        /// Photo Config 图片编辑配置项
        public var photoConfig: ImageEditorController.PhotoConfig
        
        public init(options: EditorOptions = [],
                    photoConfig: ImageEditorController.PhotoConfig = .init()) {
            self.options = options
            self.photoConfig = photoConfig
        }
    }
    
    /// Editor Options 编辑类型
    public struct EditorOptions: OptionSet {
        /// Photo 照片
        public static let photo = EditorOptions(rawValue: 1 << 0)
//        /// Video 视频
//        public static let video = CaptureMediaOptions(rawValue: 1 << 1)
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

#endif
