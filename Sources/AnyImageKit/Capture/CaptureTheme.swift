//
//  CaptureTheme.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/8.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

/// UI Theme for Editor
public struct CaptureTheme: Equatable {
    
    /// Custom color storage
    private var colors: [ColorConfigKey: UIColor] = [:]
    
    /// Custom icon storage
    private var icons: [IconConfigKey: UIImage] = [:]
    
    /// Custom string storage
    private var strings: [StringConfigKey: String] = [:]
    
    public init() {
        
    }
    
    public subscript(color key: ColorConfigKey) -> UIColor {
        get { colors[key] ?? key.defaultValue() }
        set { colors[key] = newValue }
    }
    
    public subscript(icon key: IconConfigKey) -> UIImage? {
        get { icons[key] ?? key.defaultValue() }
        set { icons[key] = newValue }
    }
    
    public subscript(string key: StringConfigKey) -> String {
        get { strings[key] ?? defaultStringValue(for: key) }
        set { strings[key] = newValue }
    }
}

// MARK: - Colors
extension CaptureTheme {
    
    public enum ColorConfigKey: Hashable {
        
        /// Main Color
        case main
        
        /// Focus view
        case focus
        
        func defaultValue() -> UIColor {
            switch self {
            case .main:
                return UIColor.color(hex: 0x57BE6A)
            case .focus:
                return UIColor.color(hex: 0xFFD60A)
            }
        }
    }
}

// MARK: - Icon
extension CaptureTheme {
    
    public enum IconConfigKey: String, Hashable {
        
        /// 48*48
        case cameraSwitch = "CameraSwitch"
        /// 27*27
        case captureSunlight = "CaptureSunlight"
        
        func defaultValue() -> UIImage? {
            return BundleHelper.image(named: rawValue, module: .capture)
        }
    }
}

// MARK: - String
extension CaptureTheme {
    
    private func defaultStringValue(for key: StringConfigKey) -> String {
        return BundleHelper.localizedString(key: key.rawValue, module: .capture)
    }
}

extension StringConfigKey {
    
    public static let captureSwitchToFrontCamera = StringConfigKey(rawValue: "SWITCH_TO_FRONT_CAMERA")
    public static let captureSwitchToBackCamera = StringConfigKey(rawValue: "SWITCH_TO_BACK_CAMERA")
    public static let captureTapForPhoto = StringConfigKey(rawValue: "TAP_FOR_PHOTO")
    public static let captureHoldForVideo = StringConfigKey(rawValue: "HOLD_FOR_VIDEO")
    public static let captureHoldForVideoTapForPhoto = StringConfigKey(rawValue: "HOLD_FOR_VIDEO_TAP_FOR_PHOTO")
}
