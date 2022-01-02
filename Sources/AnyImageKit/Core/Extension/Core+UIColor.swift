//
//  Core+UIColor.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/11/12.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
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
            return UIColor { traitCollection -> UIColor in
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
    
    static func create(style: UserInterfaceStyle, light lightColor: UIColor, dark darkColor: UIColor) -> UIColor {
        switch style {
        case .light:
            return lightColor
        case .dark:
            return darkColor
        case .auto:
            return UIColor.create(light: lightColor, dark: darkColor)
        }
    }
}
