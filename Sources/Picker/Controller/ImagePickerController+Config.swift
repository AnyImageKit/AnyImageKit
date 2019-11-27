//
//  ImagePickerController+Config.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/24.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

extension ImagePickerController {
    
    public struct Config {
        /// Theme 主题
        /// - Default: Auto
        public var theme: Theme
        
        /// Select Limit 最多可选择的资源数量
        /// - Default: 9
        public var selectLimit: Int
        
        /// Column Number 每行的列数
        /// - Default: 4
        public var columnNumber: Int
        
        /// Max Width for export Photo 导出小图的最大宽度
        /// - Default: 800
        public var photoMaxWidth: CGFloat
        
        /// Max Width for export Large Photo(When User pick original image) 导出大图的最大宽度(勾选原图时)
        /// - Default: 1200
        public var largePhotoMaxWidth: CGFloat
        
        /// Allow Use Original Image 是否允许选择原图
        /// - Default: true
        public var allowUseOriginalImage: Bool
        
        /// Album Options 相册类型
        /// - Default: Smart album
        public var albumOptions: AlbumOptions
        
        /// Select Options 可选择的类型
        /// - Default: Photo
        /// - .photoLive and .photoGIF are subtype of .photo and will be treated as a photo when not explicitly indicated, otherwise special handling will be possible (playable & proprietary)
        /// - .photoLive 和 .photoGIF 是 .photo 的子项，当不显式指明时，都会作为 photo 处理，否则会特殊处理（可播放&专有标识）
        public var selectOptions: SelectOptions
        
        /// Order by date 按日期排序
        /// - Default: ASC
        /// - ASC:  按时间升序排列，自动滚动到底部
        /// - DESC: 按时间倒序排列，自动滚动到顶部
        public var orderByDate: Sort

        /// Enable Debug Log 启用调试日志
        /// - Default: false
        public var enableDebugLog: Bool
        
        public init(theme: Theme = .init(style: .auto),
                    selectLimit: Int = 9,
                    columnNumber: Int = 4,
                    photoMaxWidth: CGFloat = 800,
                    largePhotoMaxWidth: CGFloat = 1200,
                    allowUseOriginalImage: Bool = true,
                    albumOptions: AlbumOptions = [.smart],
                    selectOptions: SelectOptions = [.photo],
                    orderByDate: Sort = .asc,
                    enableDebugLog: Bool = false) {
            self.theme = theme
            self.selectLimit = selectLimit
            self.columnNumber = columnNumber
            self.photoMaxWidth = photoMaxWidth
            self.largePhotoMaxWidth = largePhotoMaxWidth
            self.allowUseOriginalImage = allowUseOriginalImage
            self.albumOptions = albumOptions
            self.selectOptions = selectOptions
            self.orderByDate = orderByDate
            self.enableDebugLog = enableDebugLog
        }
    }
    
    /// Sort 排序规则
    public enum Sort: Equatable {
        /// ASC 升序
        case asc
        /// DESC 降序
        case desc
    }
    
    /// Select Options 可选择的类型
    public struct SelectOptions: OptionSet {
        /// Photo 照片
        public static let photo = SelectOptions(rawValue: 1 << 0)
        /// Video 视频
        public static let video = SelectOptions(rawValue: 1 << 1)
        /// GIF 动图
        public static let photoGIF = SelectOptions(rawValue: 1 << 2)
        /// Live photo 实况照片
        public static let photoLive = SelectOptions(rawValue: 1 << 3)
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
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
    
    public struct AlbumOptions: OptionSet {
        /// Smart Album, managed by system
        public static let smart = AlbumOptions(rawValue: 1 << 0)
        /// User Created Album
        public static let userCreated = AlbumOptions(rawValue: 1 << 1)
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    /// UI Theme 主题
    public struct Theme {
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
}
