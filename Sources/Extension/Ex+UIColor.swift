//
//  Ex+UIColor.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func color(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) -> UIColor {
        let divisor = CGFloat(255)
        return UIColor(red: r/divisor, green: g/divisor, blue: b/divisor, alpha: a)
    }
    
    static func color(hex: UInt32, alpha: CGFloat = 1.0) -> UIColor {
        let r = CGFloat((hex & 0xFF0000) >> 16)
        let g = CGFloat((hex & 0x00FF00) >> 8)
        let b = CGFloat((hex & 0x0000FF))
        return color(r: r, g: g, b: b, a: alpha)
    }
    
    /// 创建动态 UIColor 的方法
    /// - Parameter lightColor: light 模式下的颜色
    /// - Parameter darkColor: dark 模式下的颜色，低于 iOS 13.0 不生效
    static func create(light lightColor: UIColor, dark darkColor: UIColor?) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                if let darkColor = darkColor, traitCollection.userInterfaceStyle == .dark {
                    return darkColor
                } else {
                    return lightColor
                }
            }
        } else {
            return lightColor
        }
    }
}

extension UIColor {
    
    // MARK: - main color
    static var mainColor: UIColor {
        return UIColor.color(hex: 0x57BE6A)
    }

    // MARK: - main text
    static var mainText: UIColor {
        return UIColor.create(light: mainTextLight, dark: mainTextDark)
    }
    
    static var mainTextLight: UIColor {
        return UIColor.color(hex: 0x333333)
    }
    
    static var mainTextDark: UIColor {
        return UIColor.color(hex: 0xEAEAEA)
    }
    
    // MARK: - sub text
    static var subText: UIColor {
        return UIColor.create(light: subTextLight, dark: subTextDark)
    }
    
    static var subTextLight: UIColor {
        return UIColor.color(hex: 0x999999)
    }
    
    static var subTextDark: UIColor {
        return UIColor.color(hex: 0x6E6E6E)
    }
    
    // MARK: - toolBar
    static var toolBar: UIColor {
        return UIColor.create(light: toolBarLight, dark: toolBarDark)
    }
    
    static var toolBarLight: UIColor {
        return UIColor.color(hex: 0xF7F7F7)
    }
    
    static var toolBarDark: UIColor {
        return UIColor.color(hex: 0x5C5C5C)
    }
    
    // MARK: - background
    static var background: UIColor {
        return UIColor.create(light: backgroundLight, dark: backgroundDark)
    }
    
    static var backgroundLight: UIColor {
        return UIColor.color(hex: 0xFFFFFF)
    }
    
    static var backgroundDark: UIColor {
        return UIColor.color(hex: 0x31302F)
    }
    
    // MARK: - selected cell
    static var selectedCell: UIColor {
        return UIColor.create(light: selectedCellLight, dark: selectedCellDark)
    }
    
    static var selectedCellLight: UIColor {
        return UIColor.color(hex: 0xE4E5E9)
    }
    
    static var selectedCellDark: UIColor {
        return UIColor.color(hex: 0x171717)
    }
    
    // MARK: - separator line
    static var separatorLine: UIColor {
        return UIColor.create(light: separatorLineLight, dark: separatorLineDark)
    }
    
    static var separatorLineLight: UIColor {
        return UIColor.color(hex: 0xD6D7DA)
    }
    
    static var separatorLineDark: UIColor {
        return UIColor.color(hex: 0x454444)
    }
    
    // MARK: - button disable
    static var buttonDisable: UIColor {
        return UIColor.create(light: buttonDisableLight, dark: buttonDisableDark)
    }
    
    static var buttonDisableLight: UIColor {
        return UIColor.color(hex: 0x57BE6A).withAlphaComponent(0.3)
    }
    
    static var buttonDisableDark: UIColor {
        return UIColor.color(hex: 0x515253)
    }
    
}
