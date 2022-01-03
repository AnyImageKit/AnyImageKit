//
//  Picker+UIStatusBarStyle.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/8.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension UIStatusBarStyle {
    
    init(style: UserInterfaceStyle) {
        switch style {
        case .light:
            if #available(iOS 13.0, *) {
                self = .darkContent
            } else {
                self = .default
            }
        case .dark:
            self = .lightContent
        case .auto:
            self = .default
        }
    }
}
