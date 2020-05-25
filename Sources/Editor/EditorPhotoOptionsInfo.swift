//
//  EditorPhotoOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

public struct EditorPhotoOptionsInfo: Equatable {
    
    /// 主题色
    /// 默认：green
    public var tintColor: UIColor = Palette.main
    
    /// 编辑功能，会按顺序排布
    /// 默认：[.pen, .text, .crop, .mosaic]
    public var toolOptions: [EditorPhotoToolOption] = EditorPhotoToolOption.allCases
    
    /// 画笔颜色，会按顺序排布
    /// 默认：[white, black, red, yellow, green, blue, purple]
    public var penColors: [UIColor] = Palette.penColors
    
    /// 默认选中画笔的下标
    /// 默认：2
    public var defaultPenIndex: Int = 2
    
    /// 画笔宽度
    /// 默认：5.0
    public var penWidth: CGFloat = 5.0
    
    /// 马赛克的种类，会按顺序排布
    /// 默认：[.default, .colorful]
    public var mosaicOptions: [EditorPhotoMosaicOption] = EditorPhotoMosaicOption.allCases
    
    /// 默认选中马赛克的下标
    /// 默认：0
    public var defaultMosaicIndex: Int = 0
    
    /// 马赛克线条宽度
    /// 默认：15.0
    public var mosaicWidth: CGFloat = 15.0
    
    /// 马赛克模糊度，仅用于默认马赛克样式
    /// 默认：30
    public var mosaicLevel: Int = 30
    
    /// 文字颜色，会按顺序排布
    /// 默认：[white, black, red, yellow, green, blue, purple]
    public var textColors: [EditorPhotoTextColor] = Palette.textColors
    
    /// 裁剪尺寸，会按顺序排布
    /// 默认：[.free, 1:1, 3:4, 4:3, 9:16, 16:9]
    public var cropOptions: [EditorCropOption] = EditorCropOption.allCases
    
    /// 缓存ID
    /// 默认："" 不启用
    public var cacheIdentifier: String = ""
    
    /// 启用调试日志
    /// 默认：false
    public var enableDebugLog: Bool = false
    
    public init() { }
}

/// 图片编辑功能
public enum EditorPhotoToolOption: Equatable, CaseIterable {
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
public enum EditorPhotoMosaicOption: Equatable, CaseIterable {
    
    /// 默认马赛克
    case `default`
    /// 自定义马赛克
    case custom(icon: UIImage?, mosaic: UIImage)
    
    public static var colorful: EditorPhotoMosaicOption {
        return .custom(icon: nil, mosaic: BundleHelper.image(named: "CustomMosaic")!)
    }
    
    public static var allCases: [EditorPhotoMosaicOption] {
        return [.default, .colorful]
    }
}

/// 输入文本颜色
public struct EditorPhotoTextColor: Equatable {
    /// 主色
    public let color: UIColor
    /// 辅色
    public let subColor: UIColor
}

/// 裁剪比例
public enum EditorCropOption: Equatable, CaseIterable {
    /// 自由裁剪
    case free
    /// 自定义裁剪 宽高比
    case custom(w: UInt, h: UInt)
    
    public static var allCases: [EditorCropOption] {
        return [.free, .custom(w: 1, h: 1), .custom(w: 3, h: 4), .custom(w: 4, h: 3), .custom(w: 9, h: 16), .custom(w: 16, h: 9)]
    }
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
