//
//  ImagePickerController+HUD.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/10/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

extension ImagePickerController {
    
    internal func showWaitHUD() {
        createHUDWindowIfNeeded()
        hud.wait()
    }
    
    internal func showMessageHUD(_ message: String) {
        createHUDWindowIfNeeded()
        hud.show(message: message)
    }
    
    internal func hideHUD() {
        hud.hide()
    }
    
    private func createHUDWindowIfNeeded() {
        if hudWindow == nil {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.alpha = 1
            window.isHidden = false
            window.windowLevel = .alert
            window.rootViewController = hud
            hud.hudDidHide = { [weak self] in
                self?.hudWindow = nil
            }
            hudWindow = window
        }
    }
}
