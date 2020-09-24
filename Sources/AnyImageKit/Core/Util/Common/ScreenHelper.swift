//
//  ScreenHelper.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/10/24.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

struct ScreenHelper {
    
    static var mainBounds: CGRect {
        if #available(iOS 13, *) {
            for scene in UIApplication.shared.connectedScenes {
                if scene.activationState == .foregroundActive {
                    if let delegate = scene.delegate as? UIWindowSceneDelegate {
                        if let frame = delegate.window??.bounds {
                            return frame
                        }
                    }
                }
            }
        }
        return UIApplication.shared.windows[0].bounds
    }
}
