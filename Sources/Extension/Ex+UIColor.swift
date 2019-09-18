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
}

// MARK: - Wechat Theme
// TODO: remove to theme

extension UIColor {
    
    static var wechat_green: UIColor { UIColor.color(hex: 0x57BE6A) }
    
    static var wechat_dark_text: UIColor { UIColor.color(hex: 0xEAEAEA) }
    
    static var wechat_dark_subText: UIColor { UIColor.color(hex: 0x6E6E6E) }
    
    static var wechat_dark_background: UIColor { UIColor.color(hex: 0x31302F) }
    
    static var wechat_dark_background_selected: UIColor { UIColor.color(hex: 0x171717) }
    
    static var wechat_dark_separatorLine: UIColor { UIColor.color(hex: 0x454444) }
}
