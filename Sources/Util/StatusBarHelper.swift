//
//  StatusBarHelper.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/25.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

struct StatusBarHelper {
    
    static var height: CGFloat {
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                return windowScene.statusBarManager?.statusBarFrame.height ?? defaultHeight
            } else {
                // Should never use this code.
                return UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? defaultHeight
            }
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    private static var defaultHeight: CGFloat {
        return UIDevice.isMordenPhone ? 44 : 20
    }
}
