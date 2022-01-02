//
//  Brush.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

/// 画笔，描述 path 的样式
struct Brush: Codable {
    
    private var red : CGFloat = 0.0
    private var green: CGFloat = 0.0
    private var blue: CGFloat = 0.0
    
    var lineWidth: CGFloat = 5.0
}

extension Brush {
    
    var color: UIColor {
        get {
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        } set {
            newValue.getRed(&red, green: &green, blue: &blue, alpha: nil)
        }
    }
}
