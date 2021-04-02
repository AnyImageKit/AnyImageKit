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
