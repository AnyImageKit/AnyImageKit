//
//  ScreenHelper.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/10/24.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

struct ScreenHelper {
    
    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            let connectedScenes = UIApplication.shared.connectedScenes
            let scene = connectedScenes.first(where: { $0.activationState == .foregroundActive && $0 is UIWindowScene }) ?? connectedScenes.first(where: { $0.activationState == .foregroundInactive && $0 is UIWindowScene })
            return scene
                .flatMap({ $0 as? UIWindowScene })?
                .windows
                .first(where: { $0.isKeyWindow })
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    static var statusBarFrame: CGRect {
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let statusBarFrame = windowScene.statusBarManager?.statusBarFrame {
                return statusBarFrame
            } else {
                return .zero
            }
        } else {
            return UIApplication.shared.statusBarFrame
        }
    }
    
    static var mainBounds: CGRect {
        if #available(iOS 13.0, *) {
            let keyWindow = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .compactMap { $0 }
                .first?.windows
                .filter { $0.isKeyWindow }.first
            return keyWindow?.bounds ?? .zero
        } else {
            return UIApplication.shared.windows[0].bounds
        }
    }
}
