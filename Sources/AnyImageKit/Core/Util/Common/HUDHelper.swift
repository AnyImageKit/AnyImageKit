//
//  HUDHelper.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/21.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

private var hudWindow: UIWindow?
private var _hud: HUDViewController?
private var hud: HUDViewController? {
    if _hud == nil {
        _hud = HUDViewController()
    }
    return _hud
}

func _showWaitHUD(_ controller: UIViewController, _ message: String = "") {
    Thread.runOnMain {
        createHUDWindowIfNeeded()
        hud?.setStatusBar(with: controller)
        hud?.wait(message: message)
    }
}

func _showMessageHUD(_ controller: UIViewController, _ message: String) {
    Thread.runOnMain {
        createHUDWindowIfNeeded()
        hud?.setStatusBar(with: controller)
        hud?.show(message: message)
    }
}

func _hideHUD(_ controller: UIViewController, animated: Bool = true) {
    Thread.runOnMain {
        hud?.setStatusBar(with: controller)
        hud?.hide(animated: animated)
    }
}

private func createHUDWindowIfNeeded() {
    if hudWindow == nil {
        let window = UIWindow(frame: ScreenHelper.mainBounds)
        window.alpha = 1
        window.isHidden = false
        window.windowLevel = .alert
        window.rootViewController = hud
        hud?.hudDidHide = {
            hudWindow = nil
            _hud = nil
        }
        hudWindow = window
    }
}
