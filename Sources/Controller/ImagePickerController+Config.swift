//
//  ImagePickerController+Config.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/24.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import Photos

extension ImagePickerController {
    
    public struct Config {
        /// Theme 主题
        public var theme: Theme = Theme(style: .auto)
        
        /// Max Count 最多可选择的图片数量
        /// - Default: 9
        public var maxCount: Int = 9
        
        /// Column Number 每行的列数
        /// - Default: 4
        public var columnNumber: Int = 4
        
        /// Max Width for export Photo 导出小图的最大宽度
        /// - Default: 800
        public var photoMaxWidth: CGFloat = 800
        
        /// Max Width for export Large Photo(When User pick original image) 导出大图的最大宽度(勾选原图时)
        /// - Default: 1200
        public var largePhotoMaxWidth: CGFloat = 1200
        
        /// Allow Use Original Image 是否允许选择原图
        /// - Default: true
        public var allowUseOriginalImage: Bool = true
        
        /// Select Options 可选择的类型
        /// - Default: Photo & Video
        public var selectOptions: SelectOptions = [.photo, .video]
        
        /// Order by date 按日期排序
        /// - ASC:  按时间升序排列，自动滚动到底部
        /// - DESC: 按时间倒序排列，自动滚动到顶部
        public var orderByDate: Sort = .asc
        
        public init() { }
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
        public static let photo: SelectOptions = SelectOptions(rawValue: 1 << 0)
        /// Video 视频
        public static let video: SelectOptions = SelectOptions(rawValue: 1 << 1)
        /// GIF 动图
        public static let photoGIF: SelectOptions = SelectOptions(rawValue: 1 << 2)
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        var mediaTypes: [PHAssetMediaType] {
            var result: [PHAssetMediaType] = []
            if contains(.photo) || contains(.photoGIF) {
                result.append(.image)
            }
            if contains(.video) {
                result.append(.video)
            }
            return result
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
    
    /// User Interface Style 主题风格
    public enum UserInterfaceStyle {
        /// Auto model 自动模式
        /// - iOS 13+ depend on system, below iOS 13 equal to Light mode
        /// - iOS 13+ 会根据系统样式自动更改，低于 iOS 13 为 Light mode
        case auto
        /// Light mode 浅色模式
        case light
        /// Dark mode 深色模式
        case dark
    }
}
