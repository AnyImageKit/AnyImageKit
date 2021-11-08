//
//  CaptureTheme.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/8.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

/// UI Theme for Editor
public struct CaptureTheme: Equatable, StringConfigProtocol {
    
    /// Custom color storage
    private var colors: [ColorConfigKey: UIColor] = [:]
    
    /// Custom icon storage
    private var icons: [IconConfigKey: UIImage] = [:]
    
    /// Custom string storage
    private var strings: [StringConfigKey: String] = [:]
    
    /// Config label
    internal var labelConfiguration: [LabelConfigKey: LabelConfigObject] = [:]
    
    /// Config button
    internal var buttonConfiguration: [ButtonConfigKey: ButtonConfigObject] = [:]
    
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
    
    public mutating func configLabel(for key: LabelConfigKey, configurable: @escaping ((UILabel) -> Void)) {
        labelConfiguration[key] = LabelConfigObject(key: key, configurable: configurable)
    }
    
    public mutating func configButton(for key: ButtonConfigKey, configurable: @escaping ((UIButton) -> Void)) {
        buttonConfiguration[key] = ButtonConfigObject(key: key, configurable: configurable)
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

// MARK: - Label
extension CaptureTheme {
    
    struct LabelConfigObject: Equatable {
        let key: LabelConfigKey
        let configurable: ((UILabel) -> Void)
        
        static func == (lhs: CaptureTheme.LabelConfigObject, rhs: CaptureTheme.LabelConfigObject) -> Bool {
            return lhs.key == rhs.key
        }
    }
    
    public enum LabelConfigKey: Hashable {
        
        case tips
    }
}

// MARK: - Button
extension CaptureTheme {
    
    struct ButtonConfigObject: Equatable {
        let key: ButtonConfigKey
        let configurable: ((UIButton) -> Void)
        
        static func == (lhs: CaptureTheme.ButtonConfigObject, rhs: CaptureTheme.ButtonConfigObject) -> Bool {
            return lhs.key == rhs.key
        }
    }
    
    public enum ButtonConfigKey: Hashable {
        
        case cancel
        case switchCamera
    }
}
