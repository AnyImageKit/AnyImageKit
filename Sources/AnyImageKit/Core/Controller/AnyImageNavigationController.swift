//
//  AnyImageNavigationController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/3.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import SnapKit

open class AnyImageNavigationController: UINavigationController {
    
    private var hasOverrideGeneratingDeviceOrientation: Bool = false
    
    open weak var trackDelegate: ImageKitDataTrackDelegate?
    
    open var tag: Int = 0
    
    open var enableForceUpdate: Bool = false
    
    open override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    open override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? [.portrait]
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}

// MARK: - DataTrackObserver
extension AnyImageNavigationController: DataTrackObserver {
    
    func track(page: AnyImagePage, state: AnyImagePageState) {
        trackDelegate?.dataTrack(page: page, state: state)
    }
    
    func track(event: AnyImageEvent, userInfo: [AnyImageEventUserInfoKey: Any]) {
        trackDelegate?.dataTrack(event: event, userInfo: userInfo)
    }
}

extension AnyImageNavigationController {
    
    func beginGeneratingDeviceOrientationNotifications() {
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            hasOverrideGeneratingDeviceOrientation = true
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
    }
    
    func endGeneratingDeviceOrientationNotifications() {
        if UIDevice.current.isGeneratingDeviceOrientationNotifications && hasOverrideGeneratingDeviceOrientation {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
            hasOverrideGeneratingDeviceOrientation = false
        }
    }
}
