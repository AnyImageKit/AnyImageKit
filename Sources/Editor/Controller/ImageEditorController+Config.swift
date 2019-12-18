//
//  ImageEditorController+Config.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

extension ImageEditorController {
    
    public struct PhotoConfig {
        
        /// 主题色
        /// 默认：green
        public var tintColor: UIColor
        
        /// 编辑功能，会按顺序排布
        /// 默认：[.pen, .text, .crop, .mosaic]
        public var editOptions: [PhotoEditOption]
        
        /// 画笔颜色，会按顺序排布
        /// 默认：[white, black, red, yellow, green, blue, purple]
        public var penColors: [UIColor]
        
        /// 默认选中画笔的下标
        /// 默认：2
        public var defaultPenIdx: Int
        
        /// 画笔宽度
        /// 默认：5.0
        public var penWidth: CGFloat
        
        /// 马赛克的种类，会按顺序排布
        /// 默认：[.default, .colorful]
        public var mosaicOptions: [PhotoMosaicOption]
        
        /// 默认选中马赛克的下标
        /// 默认：0
        public var defaultMosaicIdx: Int
        
        /// 马赛克线条宽度
        /// 默认：15.0
        public var mosaicWidth: CGFloat
        
        /// 马赛克模糊度，仅用于默认马赛克样式
        /// 默认：30
        public var mosaicLevel: Int
        
        /// 文字颜色，会按顺序排布
        /// 默认：[white, black, red, yellow, green, blue, purple]
        public var textColors: [PhotoTextColor]
        
        /// 缓存ID
        /// 默认：""
        public var cacheIdentifier: String
        
        /// 启用调试日志
        /// 默认：false
        public var enableDebugLog: Bool
        
        public init(tintColor: UIColor = Palette.main,
                    editOptions: [PhotoEditOption] = [.pen, .text, .crop, .mosaic],
                    penColors: [UIColor] = Palette.penColors,
                    defaultPenIdx: Int = 2,
                    penWidth: CGFloat = 5.0,
                    mosaicOptions: [PhotoMosaicOption] = [.default, .colorful],
                    defaultMosaicIdx: Int = 0,
                    mosaicLevel: Int = 30,
                    mosaicWidth: CGFloat = 15.0,
                    textColors: [PhotoTextColor] = Palette.textColors,
                    cacheIdentifier: String = "",
                    enableDebugLog: Bool = false) {
            self.tintColor = tintColor
            self.editOptions = editOptions
            self.penColors = penColors
            self.defaultPenIdx = defaultPenIdx
            self.penWidth = penWidth
            self.mosaicOptions = mosaicOptions
            self.defaultMosaicIdx = defaultMosaicIdx
            self.mosaicLevel = mosaicLevel
            self.mosaicWidth = mosaicWidth
            self.textColors = textColors
            self.cacheIdentifier = cacheIdentifier
            self.enableDebugLog = enableDebugLog
        }
    }
    
    public enum PhotoEditOption {
        /// 画笔
        case pen
        /// 文字
        case text
        /// 裁剪
        case crop
        /// 马赛克
        case mosaic
    }
    
    public enum PhotoMosaicOption {
        /// 默认马赛克
        case `default`
        /// 彩色图片马赛克
        case colorful
        /// 自定义马赛克
        case custom(icon: UIImage, mosaic: UIImage)
    }
    
    public struct PhotoTextColor {
        /// 主色
        public let color: UIColor
        /// 辅色
        public let subColor: UIColor
    }
}

// MARK: - Extension
extension ImageEditorController.PhotoEditOption {
    var imageName: String {
        switch self {
        case .pen:
            return "PhotoToolPen"
        case .text:
            return "PhotoToolText"
        case .crop:
            return "PhotoToolCrop"
        case .mosaic:
            return "PhotoToolMosaic"
        }
    }
}
