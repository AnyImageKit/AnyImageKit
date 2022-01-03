//
//  Picker+UIBlurEffect.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/7.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension UIBlurEffect.Style {
    
    init(uiStyle: UserInterfaceStyle, traitCollection: UITraitCollection) {
        let style: UIBlurEffect.Style
        switch uiStyle {
        case .auto:
            if #available(iOS 13.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    style = .dark
                } else {
                    style = .light
                }
            } else {
                style = .light
            }
        case .light:
            style = .light
        case .dark:
            style = .dark
        }
        self.init(rawValue: style.rawValue)!
    }
}
