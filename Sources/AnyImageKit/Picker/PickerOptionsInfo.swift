//
//  PickerOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

public struct PickerOptionsInfo {
    
    /// Theme 主题
    /// - Default: Auto
    public var theme: PickerTheme = .init(style: .auto)
    
    /// Select Limit 最多可选择的资源数量
    /// - Default: 9
    public var selectLimit: Int = 9
    
    /// Column Number 每行的列数
    /// - Default: 4
    public var columnNumber: Int = 4
    
    /// Auto Calculate Column Number 自动计算每行的列数
    /// In iOS column number is `columnNumber`, in iPadOS column number will calculated by device orientation or device size.
    /// iOS 上列数以 `columnNumber` 为准，iPadOS 上将根据设备方向、大小自动计算列数
    /// - Default: true
    public var autoCalculateColumnNumber: Bool = true
    
    /// Max Width for export Photo 导出小图的最大宽度
    /// - Default: 800
    public var photoMaxWidth: CGFloat = 800
    
    /// Max Width for export Large Photo(When User pick original image) 导出大图的最大宽度(勾选原图时)
    /// - Default: 1200
    public var largePhotoMaxWidth: CGFloat = 1200
    
    /// Allow Use Original Image 是否允许选择原图
    /// - Default: false
    public var allowUseOriginalImage: Bool = false
    
    /// Album Options 相册类型
    /// - Default: smart album + user create album
    public var albumOptions: PickerAlbumOption = [.smart, .userCreated]
    
    /// Select Options 可选择的类型
    /// - Default: Photo
    /// - .photoLive and .photoGIF are subtype of .photo and will be treated as a photo when not explicitly indicated, otherwise special handling will be possible (playable & proprietary)
    /// - .photoLive 和 .photoGIF 是 .photo 的子项，当不显式指明时，都会作为 photo 处理，否则会特殊处理（可播放&专有标识）
    public var selectOptions: PickerSelectOption = [.photo]
    
    /// Selection Tap Action 资源列表点击动作
    /// - Default: Preview
    public var selectionTapAction: PickerSelectionTapAction = .preview
    
    /// Order by date 按日期排序
    /// - Default: ASC
    /// - ASC:  按时间升序排列，自动滚动到底部
    /// - DESC: 按时间倒序排列，自动滚动到顶部
    public var orderByDate: Sort = .asc
    
    /// Preselect assets 预选择资源
    /// - Default: []
    public var preselectAssets: [String] = []
    
    /// Disable Rules 资源禁用规则
    /// - Default: []
    public var disableRules: [AssetDisableCheckRule] = []
    
    /// Enable Debug Log 启用调试日志
    /// - Default: false
    public var enableDebugLog: Bool = false
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    /// Save edited asset when picker dismiss with success
    /// - Default: true
    /// - 完成选择后保存编辑过的资源
    public var saveEditedAsset: Bool = true
    
    /// Editor Options 可编辑资源类型
    /// - Default: []
    public var editorOptions: PickerEditorOption = []
    
    /// Editor photo option info items 图片编辑配置项
    public var editorPhotoOptions: EditorPhotoOptionsInfo = .init()
    
    /// Editor video option info items 视频编辑配置项
    /*public*/ var editorVideoOptions: EditorVideoOptionsInfo = .init()
    #endif
    
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    /// Capture option info items 相机配置项
    public var captureOptions: CaptureOptionsInfo = .init()
    #endif
    
    #if ANYIMAGEKIT_ENABLE_EDITOR && ANYIMAGEKIT_ENABLE_CAPTURE
    /// Use Same Editor Options In Capture 在相机中使用相同的编辑配置项
    /// - Default: true
    public var useSameEditorOptionsInCapture: Bool = true
    #endif
    
    public init() {
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        captureOptions.mediaOptions = []
        #endif
    }
}

/// Select Options 可选择的类型
public struct PickerSelectOption: OptionSet {
    /// Photo 照片
    public static let photo = PickerSelectOption(rawValue: 1 << 0)
    /// Video 视频
    public static let video = PickerSelectOption(rawValue: 1 << 1)
    /// GIF 动图
    public static let photoGIF = PickerSelectOption(rawValue: 1 << 2)
    /// Live Photo 实况照片
    public static let photoLive = PickerSelectOption(rawValue: 1 << 3)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public var isPhoto: Bool {
        return contains(.photo) || contains(.photoGIF) || contains(.photoLive)
    }
    
    public var isVideo: Bool {
        return contains(.video)
    }
}

/// Album Options 相册类型
public struct PickerAlbumOption: OptionSet {
    /// Smart Album, managed by system 智能相册
    public static let smart = PickerAlbumOption(rawValue: 1 << 0)
    /// User Created Album 用户相册
    public static let userCreated = PickerAlbumOption(rawValue: 1 << 1)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// Editor Options 编辑类型
public struct PickerEditorOption: OptionSet {
    /// Photo 照片
    public static let photo = PickerEditorOption(rawValue: 1 << 0)
    /// Video not finish 视频 未完成
    static let video = PickerEditorOption(rawValue: 1 << 1)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// Picker Selection Tap Action 资源列表点击动作
public enum PickerSelectionTapAction: Equatable {
    /// Preview 预览
    /// - Default value
    case preview
    /// Quick pick 快速选择
    /// - It will select photo instead of show preview controller when you click photo on asset picker controller
    /// - 点击图片时会直接选中该图片，而不会进入预览页面
    case quickPick
    /// Open editor 打开编辑器
    /// - It will open Editor instead of show preview controller when you click photo on asset picker controller
    /// - 点击图片后会进入编辑器，而不会进入预览页面
    case openEditor
}

/// UI Theme 主题
public struct PickerTheme: Equatable {
    /// User Interface Style 界面风格
    public let style: UserInterfaceStyle
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
    
    public init(style: UserInterfaceStyle) {
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
    
    public init(style: UserInterfaceStyle,
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
extension PickerSelectOption {
    
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

extension PickerSelectionTapAction {
    
    var hideToolBar: Bool {
        switch self {
        case .quickPick, .openEditor:
            return true
        default:
            return false
        }
    }
}
