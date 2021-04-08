//
//  PickerTheme.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/2.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

/// UI Theme for Picker
public struct PickerTheme: Equatable {
    
    /// User Interface Style
    public let style: UserInterfaceStyle
    
    /// Custom color storage
    private var colors: [ColorConfigKey: UIColor] = [:]
    
    /// Custom icon storage
    private var icons: [IconConfigKey: UIImage] = [:]
    
    public init(style: UserInterfaceStyle) {
        self.style = style
    }
    
    public subscript(color key: ColorConfigKey) -> UIColor {
        get { colors[key] ?? key.defaultValue(for: style) }
        set { colors[key] = newValue }
    }
    
    public subscript(icon key: IconConfigKey) -> UIImage? {
        get { icons[key] ?? key.defaultValue(for: style) }
        set { icons[key] = newValue }
    }
}

// MARK: - Colors
extension PickerTheme {
    
    public enum ColorConfigKey: Hashable {
        
        /// Main Color
        case main
        
        /// Text Color
        case text
        
        /// Sub Text Color
        case subText
        
        /// ToolBar Color
        case toolBar
        
        /// Background Color
        case background
        
        /// TableView Cell Selected Background Color
        case selectedCell
        
        /// Separator Line Color
        case separatorLine
        
        func defaultValue(for style: UserInterfaceStyle) -> UIColor {
            switch style {
            case .auto:
                switch self {
                case .main: return UIColor.mainColor
                case .text: return UIColor.mainText
                case .subText: return UIColor.subText
                case .toolBar: return UIColor.toolBar
                case .background: return UIColor.background
                case .selectedCell: return UIColor.selectedCell
                case .separatorLine: return UIColor.separatorLine
                }
            case .light:
                switch self {
                case .main: return UIColor.mainColor
                case .text: return UIColor.mainTextLight
                case .subText: return UIColor.subTextLight
                case .toolBar: return UIColor.toolBarLight
                case .background: return UIColor.backgroundLight
                case .selectedCell: return UIColor.selectedCellLight
                case .separatorLine: return UIColor.separatorLineLight
                }
            case .dark:
                switch self {
                case .main: return UIColor.mainColor
                case .text: return UIColor.mainTextDark
                case .subText: return UIColor.subTextDark
                case .toolBar: return UIColor.toolBarDark
                case .background: return UIColor.backgroundDark
                case .selectedCell: return UIColor.selectedCellDark
                case .separatorLine: return UIColor.separatorLineDark
                }
            }
        }
    }
}

// MARK: - Icon
extension PickerTheme {
    
    public enum IconConfigKey: Hashable {
        
        /// 20*20, Light/Dark
        case albumArrow
        
        /// 20*20, Light/Dark
        case arrowRight
        
        /// 50*50
        case camera
        
        /// 16*16
        case checkOff
        
        /// 16*16, Template
        case checkOn
        
        /// 20*20
        case iCloud
        
        /// 20*20, Light/Dark
        case livePhoto
        
        /// 24*24
        case photoEdited
        
        /// 24*24, Light/Dark
        case pickerCircle
        
        /// 14*24, Light/Dark
        case returnButton
        
        /// 24*15
        case video
        
        /// 80*80
        case videoPlay
        
        /// 20*20, Light/Dark
        case warning
        
        func defaultValue(for style: UserInterfaceStyle) -> UIImage? {
            switch self {
            case .albumArrow:
                return BundleHelper.image(named: "AlbumArrow", style: style, module: .picker)
            case .arrowRight:
                return BundleHelper.image(named: "ArrowRight", style: style, module: .picker)
            case .camera:
                return BundleHelper.image(named: "Camera", module: .picker)
            case .checkOff:
                return BundleHelper.image(named: "CheckOff", module: .picker)
            case .checkOn:
                return BundleHelper.image(named: "CheckOn", module: .picker)?.withRenderingMode(.alwaysTemplate)
            case .iCloud:
                return BundleHelper.image(named: "iCloud", module: .picker)
            case .livePhoto:
                return BundleHelper.image(named: "LivePhoto", style: style, module: .picker)
            case .photoEdited:
                return BundleHelper.image(named: "PhotoEdited", module: .picker)
            case .pickerCircle:
                return BundleHelper.image(named: "PickerCircle", style: style, module: .picker)
            case .returnButton:
                return BundleHelper.image(named: "ReturnButton", style: style, module: .picker)
            case .video:
                return BundleHelper.image(named: "Video", module: .picker)
            case .videoPlay:
                return BundleHelper.image(named: "VideoPlay", module: .picker)
            case .warning:
                return BundleHelper.image(named: "Warning", style: style, module: .picker)
            }
        }
    }
}
