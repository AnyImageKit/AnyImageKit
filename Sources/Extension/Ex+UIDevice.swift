//
//  Ex+UIDevice.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/18.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

extension UIDevice {
    
    static var isMordenPhone: Bool {
        let size = UIScreen.main.bounds.size
        switch size {
        /// iPhone X/Xs/11Pro
        case CGSize(width: 375, height: 812), CGSize(width: 812, height: 375):
            return true
        /// iPhone XsMax/Xr/11/11ProMax
        case CGSize(width: 414, height: 896), CGSize(width: 896, height: 414):
            return true
        default:
            return false
        }
    }
}
