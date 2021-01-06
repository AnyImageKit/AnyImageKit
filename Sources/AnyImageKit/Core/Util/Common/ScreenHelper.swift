//
//  ScreenHelper.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/10/24.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

struct ScreenHelper {
    
    static var statusBarFrame: CGRect {
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let statusBarFrame = windowScene.statusBarManager?.statusBarFrame {
                return statusBarFrame
            }
        }
        return UIApplication.shared.statusBarFrame
    }
    
    static var mainBounds: CGRect {
        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                if scene.activationState == .foregroundActive, let delegate = scene.delegate as? UIWindowSceneDelegate, let bounds = delegate.window??.bounds {
                    return bounds
                }
            }
        }
        return UIApplication.shared.windows[0].bounds
    }
}
