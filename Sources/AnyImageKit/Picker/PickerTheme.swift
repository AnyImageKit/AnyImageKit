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
    
    public init(style: UserInterfaceStyle) {
        self.style = style
    }
    
    public subscript(color key: ColorConfigKey) -> UIColor {
        get { colors[key] ?? key.defaultValue(for: style) }
        set { colors[key] = newValue }
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
        /// Button Disable Color
        case buttonDisable
        
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
                case .buttonDisable: return UIColor.buttonDisable
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
                case .buttonDisable: return UIColor.buttonDisableLight
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
                case .buttonDisable: return UIColor.buttonDisableDark
                }
            }
        }
    }
}
