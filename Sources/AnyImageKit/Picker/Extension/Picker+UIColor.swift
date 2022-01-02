//
//  Picker+UIColor.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension UIColor {
    
    // MARK: - main color
    static var primaryColor: UIColor {
        return UIColor.color(hex: 0x57BE6A)
    }

    // MARK: - main text
    static var primaryText: UIColor {
        return UIColor.create(light: primaryTextLight, dark: primaryTextDark)
    }
    
    static var primaryTextLight: UIColor {
        return UIColor.color(hex: 0x333333)
    }
    
    static var primaryTextDark: UIColor {
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
        return UIColor.color(hex: 0x31302F)
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
}
