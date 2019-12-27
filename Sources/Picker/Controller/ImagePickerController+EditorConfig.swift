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
        public var photoConfig: AnyImageEditorPhotoOptionsInfo
        
        /// Video Config 视频编辑配置项
        public var videoConfig: AnyImageEditorVideoOptionsInfo
        
        public init(options: EditorOptions = [],
                    photoConfig: AnyImageEditorPhotoOptionsInfo = .init(),
                    videoConfig: AnyImageEditorVideoOptionsInfo = .init()) {
            self.options = options
            self.photoConfig = photoConfig
            self.videoConfig = videoConfig
        }
    }
    
    /// Editor Options 编辑类型
    public struct EditorOptions: OptionSet {
        /// Photo 照片
        public static let photo = EditorOptions(rawValue: 1 << 0)
        /// Video not finish 视频 未完成
        static let video = EditorOptions(rawValue: 1 << 1)
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

#endif
