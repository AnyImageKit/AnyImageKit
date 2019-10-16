//
//  ImagePickerController+Config.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/24.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

extension ImagePickerController {
    
    public struct Config {
        /// 主题
        public var theme: Theme = Theme(style: .auto)
        
        /// 最多可选择的图片数量
        public var maxCount: Int = 9
        
        /// 一行的列数
        public var columnNumber: Int = 4
        
        /// 导出小图的最大宽度
        public var photoMaxWidth: CGFloat = 800
        
        /// 导出大图的最大宽度(勾选原图时)
        public var largePhotoMaxWidth: CGFloat = 1200
        
        /// 是否显示原图
        public var allowUseOriginalPhoto: Bool = true
        
        /// 可选择的类型，默认可选择图片+视频
        public var selectOptions: SelectOptions = [.photo, .video]
        
        /// 按日期排序
        /// asc:  按时间升序排列，自动滚动到底部
        /// desc: 按时间倒序排列，自动滚动到顶部
        public var orderByDate: Sort = .asc
        
        public init() {
            
        }
    }
    
    /// 排序规则
    public enum Sort: Equatable {
        /// 升序
        case asc
        /// 降序
        case desc
    }
    
    /// 可选择的类型
    public struct SelectOptions: OptionSet {
        /// 照片(包括GIF)
        public static let photo: SelectOptions = SelectOptions(rawValue: 1 << 0)
        /// 视频
        public static let video: SelectOptions = SelectOptions(rawValue: 1 << 1)
        
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    /// 主题
    public struct Theme {
        public let style: UserInterfaceStyle
        
        public var mainColor: UIColor
        public var textColor: UIColor
        public var subTextColor: UIColor
        public var toolBarColor: UIColor
        public var backgroundColor: UIColor
        public var backgroundSelectedColor: UIColor
        public var separatorLineColor: UIColor
        public var buttonDisableBackgroundColor: UIColor
        
        public init(style: UserInterfaceStyle) {
            switch style {
            case .auto:
                self.init(style: .auto,
                          mainColor: UIColor.mainColor,
                          textColor: UIColor.mainText,
                          subTextColor: UIColor.subText,
                          toolBarColor: UIColor.toolBar,
                          backgroundColor: UIColor.background,
                          backgroundSelectedColor: UIColor.backgroundSelected,
                          separatorLineColor: UIColor.separatorLine,
                          buttonDisableBackgroundColor: UIColor.buttonDisableBackground)
            case .light:
                self.init(style: .light,
                          mainColor: UIColor.mainColor,
                          textColor: UIColor.mainTextLight,
                          subTextColor: UIColor.subTextLight,
                          toolBarColor: UIColor.toolBarLight,
                          backgroundColor: UIColor.backgroundLight,
                          backgroundSelectedColor: UIColor.backgroundSelectedLight,
                          separatorLineColor: UIColor.separatorLineLight,
                          buttonDisableBackgroundColor: UIColor.buttonDisableBackgroundLight)
            case .dark:
                self.init(style: .dark,
                          mainColor: UIColor.mainColor,
                          textColor: UIColor.mainTextDark,
                          subTextColor: UIColor.subTextDark,
                          toolBarColor: UIColor.toolBarDark,
                          backgroundColor: UIColor.backgroundDark,
                          backgroundSelectedColor: UIColor.backgroundSelectedDark,
                          separatorLineColor: UIColor.separatorLineDark,
                          buttonDisableBackgroundColor: UIColor.buttonDisableBackgroundDark)
            }
        }
        
        public init(style: UserInterfaceStyle,
                    mainColor: UIColor,
                    textColor: UIColor,
                    subTextColor: UIColor,
                    toolBarColor: UIColor,
                    backgroundColor: UIColor,
                    backgroundSelectedColor: UIColor,
                    separatorLineColor: UIColor,
                    buttonDisableBackgroundColor: UIColor) {
            self.style = style
            self.mainColor = mainColor
            self.textColor = textColor
            self.subTextColor = subTextColor
            self.toolBarColor = toolBarColor
            self.backgroundColor = backgroundColor
            self.backgroundSelectedColor = backgroundSelectedColor
            self.separatorLineColor = separatorLineColor
            self.buttonDisableBackgroundColor = buttonDisableBackgroundColor
        }
    }
    
    /// 主题风格
    public enum UserInterfaceStyle {
        /// 自动 iOS 13+ 会根据系统样式自动更改，iOS 13 以下为 Light mode
        case auto
        /// Light mode
        case light
        /// Dark mode
        case dark
    }
}
