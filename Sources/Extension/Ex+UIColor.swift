//
//  Ex+UIColor.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
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

// MARK: - Wechat Theme

extension UIColor {
    
    static var wechatGreen: UIColor {
        return UIColor.create(light: UIColor.color(hex: 0x57BE6A), dark: UIColor.color(hex: 0x57BE6A))
    }
    
    static var wechatText: UIColor {
        return UIColor.create(light: UIColor.color(hex: 0x333333), dark: UIColor.color(hex: 0xEAEAEA))
    }
    
    static var wechatSubText: UIColor {
        return UIColor.create(light: UIColor.color(hex: 0x999999), dark: UIColor.color(hex: 0x6E6E6E))
    }
    
    static var wechatToolBar: UIColor {
        return UIColor.create(light: UIColor.color(hex: 0xF7F7F7), dark: UIColor.color(hex: 0x5C5C5C))
    }
    
    static var wechatBackground: UIColor {
        return UIColor.create(light: UIColor.color(hex: 0xFFFFFF), dark: UIColor.color(hex: 0x31302F))
    }
    
    static var wechatBackgroundSelected: UIColor {
        return UIColor.create(light: UIColor.color(hex: 0xE4E5E9), dark: UIColor.color(hex: 0x171717))
    }
    
    static var wechatSeparatorLine: UIColor {
        return UIColor.create(light: UIColor.color(hex: 0xD6D7DA), dark: UIColor.color(hex: 0x454444))
    }
    
    static var wechatButtonDisableBackgroundColor: UIColor {
        return UIColor.create(light: UIColor.color(hex: 0x57BE6A).withAlphaComponent(0.3), dark: UIColor.color(hex: 0x515253))
    }
}
