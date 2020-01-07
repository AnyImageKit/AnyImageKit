//
//  EditorPhotoOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

public typealias EditorPhotoOptionsInfo = [EditorPhotoOptionsInfoItem]

public enum EditorPhotoOptionsInfoItem: OptionsInfoItem {
    
    /// 主题色
    /// 默认：green
    case tintColor(UIColor)
    
    /// 编辑功能，会按顺序排布
    /// 默认：[.pen, .text, .crop, .mosaic]
    case toolOptions([EditorPhotoToolOption])
    
    /// 画笔颜色，会按顺序排布
    /// 默认：[white, black, red, yellow, green, blue, purple]
    case penColors([UIColor])
    
    /// 默认选中画笔的下标
    /// 默认：2
    case defaultPenIndex(Int)
    
    /// 画笔宽度
    /// 默认：5.0
    case penWidth(CGFloat)
    
    /// 马赛克的种类，会按顺序排布
    /// 默认：[.default, .colorful]
    case mosaicOptions([EditorPhotoMosaicOption])
    
    /// 默认选中马赛克的下标
    /// 默认：0
    case defaultMosaicIndex(Int)
    
    /// 马赛克线条宽度
    /// 默认：15.0
    case mosaicWidth(CGFloat)
    
    /// 马赛克模糊度，仅用于默认马赛克样式
    /// 默认：30
    case mosaicLevel(Int)
    
    /// 文字颜色，会按顺序排布
    /// 默认：[white, black, red, yellow, green, blue, purple]
    case textColors([EditorPhotoTextColor])
    
    /// 缓存ID
    /// 默认："" 不启用
    case cacheIdentifier(String)
    
    /// 启用调试日志
    /// 默认：false
    case enableDebugLog
}

public struct EditorPhotoParsedOptionsInfo: Equatable {
    
    public var tintColor: UIColor = Palette.main
    public var toolOptions: [EditorPhotoToolOption] = [.pen, .text, .crop, .mosaic]
    public var penColors: [UIColor] = Palette.penColors
    public var defaultPenIndex: Int = 2
    public var penWidth: CGFloat = 5.0
    public var mosaicOptions: [EditorPhotoMosaicOption] = [.default, .colorful]
    public var defaultMosaicIndex: Int = 0
    public var mosaicWidth: CGFloat = 15.0
    public var mosaicLevel: Int = 30
    public var textColors: [EditorPhotoTextColor] = Palette.textColors
    public var cacheIdentifier: String = ""
    public var enableDebugLog: Bool = false
    
    public init(_ info: [EditorPhotoOptionsInfoItem] = []) {
        for option in info {
            switch option {
            case .tintColor(let value): tintColor = value
            case .toolOptions(let value): toolOptions = value
            case .penColors(let value): penColors = value
            case .defaultPenIndex(let value): defaultPenIndex = value
            case .penWidth(let value): penWidth = value
            case .mosaicOptions(let value): mosaicOptions = value
            case .defaultMosaicIndex(let value): defaultMosaicIndex = value
            case .mosaicWidth(let value): mosaicWidth = value
            case .mosaicLevel(let value): mosaicLevel = value
            case .textColors(let value): textColors = value
            case .cacheIdentifier(let value): cacheIdentifier = value
            case .enableDebugLog: enableDebugLog = true
            }
        }
    }
}

/// 图片编辑功能
public enum EditorPhotoToolOption: Equatable {
    /// 画笔
    case pen
    /// 文字
    case text
    /// 裁剪
    case crop
    /// 马赛克
    case mosaic
}

/// 马赛克样式
public enum EditorPhotoMosaicOption: Equatable {
    /// 默认马赛克
    case `default`
    /// 彩色图片马赛克
    case colorful
    /// 自定义马赛克
    case custom(icon: UIImage, mosaic: UIImage)
}

/// 输入文本颜色
public struct EditorPhotoTextColor: Equatable {
    /// 主色
    public let color: UIColor
    /// 辅色
    public let subColor: UIColor
}

// MARK: - Extension
extension EditorPhotoToolOption: CustomStringConvertible {
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
    
    public var description: String {
        switch self {
        case .pen:
            return "Pen"
        case .text:
            return "Input text"
        case .crop:
            return "Crop"
        case .mosaic:
            return "Mosaic"
        }
    }
}
