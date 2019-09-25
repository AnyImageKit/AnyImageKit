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
        /// UI 展示的效果
        public var theme: Theme = Theme.wechat()
        /// 最多可选择的图片数量
        public var maxCount: Int = 3
        /// 一行的列数
        public var columnNumber: Int = 4
        /// 导出图片的宽度
        public var photoWidth: Int = 1200
        /// 是否显示原图
        public var allowUseOriginalPhoto: Bool = true
        /// 可选择的类型，默认可选择图片+视频
        public var selectOptions: SelectOptions = [.photo, .video]
        /// 按日期排序
        public var orderByDate: Sort = .asc
        
        public init() {
            
        }
    }
    
    public enum Sort: Equatable {
        /// 升序
        case asc
        /// 降序
        case desc
    }
    
    public struct SelectOptions: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let photo: SelectOptions = SelectOptions(rawValue: 1 << 0)
        public static let video: SelectOptions = SelectOptions(rawValue: 1 << 1)
    }
    
    public struct Theme {
        public var style: UserInterfaceStyle
        
        public var mainColor: UIColor
        public var textColor: UIColor
        public var subTextColor: UIColor
        public var toolBarColor: UIColor
        public var backgroundColor: UIColor
        public var backgroundSelectedColor: UIColor
        public var separatorLineColor: UIColor
        
        public static func wechat(style: UserInterfaceStyle = .dark) -> Theme {
            switch style {
            case .auto:
                return Theme(style: .auto,
                mainColor: UIColor.wechatGreen,
                textColor: UIColor.wechatText,
                subTextColor: UIColor.wechatSubText,
                toolBarColor: UIColor.wechatToolBar,
                backgroundColor: UIColor.wechatBackground,
                backgroundSelectedColor: UIColor.wechatBackgroundSelected,
                separatorLineColor: UIColor.wechatSeparatorLine)
            case .light:
                fatalError()
            case .dark:
                return Theme(style: .dark,
                             mainColor: UIColor.color(hex: 0x57BE6A),
                             textColor: UIColor.color(hex: 0xEAEAEA),
                             subTextColor: UIColor.color(hex: 0x6E6E6E),
                             toolBarColor: UIColor.color(hex: 0x5C5C5C),
                             backgroundColor: UIColor.color(hex: 0x31302F),
                             backgroundSelectedColor: UIColor.color(hex: 0x171717),
                             separatorLineColor: UIColor.color(hex: 0x454444))
            }
        }
    }
    
    public enum UserInterfaceStyle {
        case auto
        case light
        case dark
        
        var currentStyle: _UserInterfaceStyle {
            switch self {
            case .auto:
                if #available(iOS 13.0, *) {
                    switch UITraitCollection.current.userInterfaceStyle {
                    case .light:
                        return .light
                    case .dark:
                        return .dark
                    default:
                        return .light
                    }
                } else {
                    return .light
                }
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }
    }
    
    enum _UserInterfaceStyle {
        case light
        case dark
    }
}
