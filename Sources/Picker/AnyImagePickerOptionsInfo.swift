//
//  AnyImagePickerOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

public enum AnyImagePickerOptionsInfoItem {
    /// Theme 主题
    /// - Default: Auto
    case theme(AnyImagePickerTheme)
    
    /// Select Limit 最多可选择的资源数量
    /// - Default: 9
    case selectLimit(Int)
    
    /// Column Number 每行的列数
    /// - Default: 4
    case columnNumber(Int)
    
    /// Max Width for export Photo 导出小图的最大宽度
    /// - Default: 800
    case photoMaxWidth(CGFloat)
    
    /// Max Width for export Large Photo(When User pick original image) 导出大图的最大宽度(勾选原图时)
    /// - Default: 1200
    case largePhotoMaxWidth(CGFloat)
    
    /// Allow Use Original Image 是否允许选择原图
    /// - Default: true
    case allowUseOriginalImage
    
    /// Album Options 相册类型
    /// - Default: smart album + user create album
    case albumOptions(AnyImagePickerAlbumOptions)
    
    /// Select Options 可选择的类型
    /// - Default: Photo
    /// - .photoLive and .photoGIF are subtype of .photo and will be treated as a photo when not explicitly indicated, otherwise special handling will be possible (playable & proprietary)
    /// - .photoLive 和 .photoGIF 是 .photo 的子项，当不显式指明时，都会作为 photo 处理，否则会特殊处理（可播放&专有标识）
    case selectOptions(AnyImagePickerSelectOptions)
    
    /// Order by date 按日期排序
    /// - Default: ASC
    /// - ASC:  按时间升序排列，自动滚动到底部
    /// - DESC: 按时间倒序排列，自动滚动到顶部
    case orderByDate(AnyImageSort)
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    case editorOptions(AnyImageEditorOptionsInfo)
    #endif
    
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    case captureOptionInfoItems([AnyImageCaptureOptionsInfoItem])
    #endif
    
    /// Enable Debug Log 启用调试日志
    /// - Default: false
    case enableDebugLog
}

public struct AnyImagePickerOptionsInfo {
    
    public var theme: AnyImagePickerTheme = .init(style: .auto)
    public var selectLimit: Int = 9
    public var columnNumber: Int = 4
    public var photoMaxWidth: CGFloat = 800
    public var largePhotoMaxWidth: CGFloat = 1200
    public var allowUseOriginalImage: Bool = true
    public var albumOptions: AnyImagePickerAlbumOptions = [.smart, .userCreated]
    public var selectOptions: AnyImagePickerSelectOptions = [.photo]
    public var orderByDate: AnyImageSort = .asc
    public var enableDebugLog: Bool = false
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    public var editorOptions: AnyImageEditorOptionsInfo = .init()
    #endif
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    public var captureOptionInfoItems: [AnyImageCaptureOptionsInfoItem] = [] {
        didSet {
            captureOptions = .init(captureOptionInfoItems)
        }
    }
    var captureOptions: AnyImageCaptureOptionsInfo = .init()
    #endif
    
    public init(_ info: [AnyImagePickerOptionsInfoItem] = []) {
        for option in info {
            switch option {
            case .theme(let value): theme = value
            case .selectLimit(let value): selectLimit = value
            case .columnNumber(let value): columnNumber = value
            case .photoMaxWidth(let value): photoMaxWidth = value
            case .largePhotoMaxWidth(let value): largePhotoMaxWidth = value
            case .allowUseOriginalImage: allowUseOriginalImage = true
            case .albumOptions(let value): albumOptions = value
            case .selectOptions(let value): selectOptions = value
            case .orderByDate(let value): orderByDate = value
            case .enableDebugLog: enableDebugLog = true
                
            #if ANYIMAGEKIT_ENABLE_EDITOR
            case .editorOptions(let value): editorOptions = value
            #endif
            #if ANYIMAGEKIT_ENABLE_CAPTURE
            case .captureOptionInfoItems(let value): captureOptionInfoItems = value
            #endif
            }
        }
    }
}

/// Select Options 可选择的类型
public struct AnyImagePickerSelectOptions: OptionSet {
    /// Photo 照片
    public static let photo = AnyImagePickerSelectOptions(rawValue: 1 << 0)
    /// Video 视频
    public static let video = AnyImagePickerSelectOptions(rawValue: 1 << 1)
    /// GIF 动图
    public static let photoGIF = AnyImagePickerSelectOptions(rawValue: 1 << 2)
    /// Live photo 实况照片
    public static let photoLive = AnyImagePickerSelectOptions(rawValue: 1 << 3)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// Album Options 相册类型
public struct AnyImagePickerAlbumOptions: OptionSet {
    /// Smart Album, managed by system 智能相册
    public static let smart = AnyImagePickerAlbumOptions(rawValue: 1 << 0)
    /// User Created Album 用户相册
    public static let userCreated = AnyImagePickerAlbumOptions(rawValue: 1 << 1)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// UI Theme 主题
public struct AnyImagePickerTheme {
    /// User Interface Style 界面风格
    public let style: AnyImageUserInterfaceStyle
    /// Main Color 主题色调
    public var mainColor: UIColor
    /// Text Color 主文本颜色
    public var textColor: UIColor
    /// Sub Text Color 辅助文本颜色
    public var subTextColor: UIColor
    /// ToolBar Color 工具栏颜色
    public var toolBarColor: UIColor
    /// Background Color 背景色
    public var backgroundColor: UIColor
    /// TableView Cell Selected Background Color 列表选中颜色
    public var selectedCellColor: UIColor
    /// Separator Line Color 分割线颜色
    public var separatorLineColor: UIColor
    /// Button Disable Color 不可用按钮颜色
    public var buttonDisableColor: UIColor
    
    public init(style: AnyImageUserInterfaceStyle) {
        switch style {
        case .auto:
            self.init(style: .auto,
                      mainColor: UIColor.mainColor,
                      textColor: UIColor.mainText,
                      subTextColor: UIColor.subText,
                      toolBarColor: UIColor.toolBar,
                      backgroundColor: UIColor.background,
                      selectedCellColor: UIColor.selectedCell,
                      separatorLineColor: UIColor.separatorLine,
                      buttonDisableColor: UIColor.buttonDisable)
        case .light:
            self.init(style: .light,
                      mainColor: UIColor.mainColor,
                      textColor: UIColor.mainTextLight,
                      subTextColor: UIColor.subTextLight,
                      toolBarColor: UIColor.toolBarLight,
                      backgroundColor: UIColor.backgroundLight,
                      selectedCellColor: UIColor.selectedCellLight,
                      separatorLineColor: UIColor.separatorLineLight,
                      buttonDisableColor: UIColor.buttonDisableLight)
        case .dark:
            self.init(style: .dark,
                      mainColor: UIColor.mainColor,
                      textColor: UIColor.mainTextDark,
                      subTextColor: UIColor.subTextDark,
                      toolBarColor: UIColor.toolBarDark,
                      backgroundColor: UIColor.backgroundDark,
                      selectedCellColor: UIColor.selectedCellDark,
                      separatorLineColor: UIColor.separatorLineDark,
                      buttonDisableColor: UIColor.buttonDisableDark)
        }
    }
    
    public init(style: AnyImageUserInterfaceStyle,
                mainColor: UIColor,
                textColor: UIColor,
                subTextColor: UIColor,
                toolBarColor: UIColor,
                backgroundColor: UIColor,
                selectedCellColor: UIColor,
                separatorLineColor: UIColor,
                buttonDisableColor: UIColor) {
        self.style = style
        self.mainColor = mainColor
        self.textColor = textColor
        self.subTextColor = subTextColor
        self.toolBarColor = toolBarColor
        self.backgroundColor = backgroundColor
        self.selectedCellColor = selectedCellColor
        self.separatorLineColor = separatorLineColor
        self.buttonDisableColor = buttonDisableColor
    }
}

// MARK: - Extension
extension AnyImagePickerOptionsInfoItem: AnyImageOptionsInfoItem {
    
    public static func ~== (lhs: AnyImagePickerOptionsInfoItem, rhs: AnyImagePickerOptionsInfoItem) -> Bool {
        switch (lhs, rhs) {
        case (.theme, .theme): return true
            // TODO:
        default: return false
        }
    }
}

extension AnyImagePickerSelectOptions {
    
    var mediaTypes: [PHAssetMediaType] {
        var result: [PHAssetMediaType] = []
        if contains(.photo) || contains(.photoGIF) || contains(.photoLive) {
            result.append(.image)
        }
        if contains(.video) {
            result.append(.video)
        }
        return result
    }
}
