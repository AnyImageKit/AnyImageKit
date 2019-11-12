//
//  ColorHelper.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/15.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

struct ColorHelper {
    
    static func createByStyle(light lightColor: UIColor, dark darkColor: UIColor) -> UIColor {
        switch PhotoManager.shared.config.theme.style {
        case .light:
            return lightColor
        case .dark:
            return darkColor
        case .auto:
            return UIColor.create(light: lightColor, dark: darkColor)
        }
    }
}
