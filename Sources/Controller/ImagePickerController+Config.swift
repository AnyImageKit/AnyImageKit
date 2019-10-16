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
        public var theme: Theme = Theme.wechat(style: .dark)
        
        /// 最多可选择的图片数量
        public var maxCount: Int = 3
        
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
        public var style: UserInterfaceStyle
        
        public var mainColor: UIColor
        public var textColor: UIColor
        public var subTextColor: UIColor
        public var toolBarColor: UIColor
        public var backgroundColor: UIColor
        public var backgroundSelectedColor: UIColor
        public var separatorLineColor: UIColor
        public var buttonDisableBackgroundColor: UIColor
        
        public static func wechat(style: UserInterfaceStyle) -> Theme {
            switch style {
            case .auto:
                return Theme(style: .auto,
                             mainColor: UIColor.wechatGreen,
                             textColor: UIColor.wechatText,
                             subTextColor: UIColor.wechatSubText,
                             toolBarColor: UIColor.wechatToolBar,
                             backgroundColor: UIColor.wechatBackground,
                             backgroundSelectedColor: UIColor.wechatBackgroundSelected,
                             separatorLineColor: UIColor.wechatSeparatorLine,
                             buttonDisableBackgroundColor: UIColor.wechatButtonDisableBackgroundColor)
            case .light:
                return Theme(style: .light,
                             mainColor: UIColor.color(hex: 0x57BE6A),
                             textColor: UIColor.color(hex: 0x333333),
                             subTextColor: UIColor.color(hex: 0x999999),
                             toolBarColor: UIColor.color(hex: 0xECECEC),
                             backgroundColor: UIColor.color(hex: 0xFFFFFF),
                             backgroundSelectedColor: UIColor.color(hex: 0xE4E5E9),
                             separatorLineColor: UIColor.color(hex: 0xD6D7DA),
                             buttonDisableBackgroundColor: UIColor.color(hex: 0x57BE6A).withAlphaComponent(0.3))
            case .dark:
                return Theme(style: .dark,
                             mainColor: UIColor.color(hex: 0x57BE6A),
                             textColor: UIColor.color(hex: 0xEAEAEA),
                             subTextColor: UIColor.color(hex: 0x6E6E6E),
                             toolBarColor: UIColor.color(hex: 0x5C5C5C),
                             backgroundColor: UIColor.color(hex: 0x31302F),
                             backgroundSelectedColor: UIColor.color(hex: 0x171717),
                             separatorLineColor: UIColor.color(hex: 0x454444),
                             buttonDisableBackgroundColor: UIColor.color(hex: 0x515253))
            }
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
