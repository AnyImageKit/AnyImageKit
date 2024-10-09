//
//  ScreenHelper.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/10/24.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

struct ScreenHelper {
    
    static var windowScene: UIWindowScene? {
        let connectedScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return (connectedScenes.first(where: { $0.activationState == .foregroundActive })) ?? connectedScenes.first(where: { $0.activationState == .foregroundInactive })
    }
    
    static var keyWindow: UIWindow? {
        return windowScene?
            .windows
            .first(where: { $0.isKeyWindow })
    }
    
    static var statusBarFrame: CGRect {
        if let windowScene = windowScene,
           let statusBarFrame = windowScene.statusBarManager?.statusBarFrame {
            return statusBarFrame
        } else {
            return .zero
        }
    }
    
    static var interfaceOrientation: UIInterfaceOrientation {
        if let windowScene = windowScene {
            return windowScene.interfaceOrientation
        } else {
            return .portrait
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
