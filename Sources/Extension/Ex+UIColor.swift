//
//  Ex+UIColor.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

extension UIColor {
    
    public static func color(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) -> UIColor {
        let divisor = CGFloat(255)
        return UIColor(red: r/divisor, green: g/divisor, blue: b/divisor, alpha: a)
    }
    
    public static func color(hex: UInt32, alpha: CGFloat = 1.0) -> UIColor {
        let r = CGFloat((hex & 0xFF0000) >> 16)
        let g = CGFloat((hex & 0x00FF00) >> 8)
        let b = CGFloat((hex & 0x0000FF))
        return color(r: r, g: g, b: b, a: alpha)
    }
}
