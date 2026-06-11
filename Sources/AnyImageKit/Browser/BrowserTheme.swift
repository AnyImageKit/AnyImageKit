//
//  BrowserTheme.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/13.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit

/// UI Theme for Browser
public final class BrowserTheme: ThemeConfigurable {
    
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
    
    /// Set custom color
    /// - Note: Please set dynamic color if your app support dark mode
    public subscript(color key: ColorConfigKey) -> UIColor {
        get { colors[key] ?? key.defaultValue() }
        set { colors[key] = newValue }
    }
    
    /// Set custom icon
    /// - Note: Please set dynamic image if your app support dark mode
    public subscript(icon key: IconConfigKey) -> UIImage? {
        get { icons[key] ?? key.defaultValue() }
        set { icons[key] = newValue }
    }
    
    /// Set custom string
    /// - Note: Please set localized text if your app support multiple languages
    public subscript(string key: StringConfigKey) -> String {
        get { strings[key] ?? defaultStringValue(for: key) }
        set { strings[key] = newValue }
    }
    
    /// Configuration Label if you needed
    /// - Note: ⚠️ DO NOT set hidden/enable properties
    public func configurationLabel(for key: LabelConfigKey, configuration: @escaping ((UILabel) -> Void)) {
        labelConfiguration[key] = LabelConfigObject(key: key, configuration: configuration)
    }
    
    /// Configuration Button if you needed
    /// - Note: ⚠️ DO NOT set hidden/enable properties
    public func configurationButton(for key: ButtonConfigKey, configuration: @escaping ((UIButton) -> Void)) {
        buttonConfiguration[key] = ButtonConfigObject(key: key, configuration: configuration)
    }
}

// MARK: - Colors
extension BrowserTheme {
    
    public enum ColorConfigKey: Hashable {
        
        /// Primary Color
        case primary
        
        /// Text Color
        case tipsText
        
        case loadingIndicator
        
        /// Background Color
        case background
        
        func defaultValue() -> UIColor {
            switch self {
            case .primary: return .white
            case .tipsText: return .white
            case .loadingIndicator: return .white
            case .background: return .black
            }
        }
    }
}

// MARK: - Icon
extension BrowserTheme {
    
    public enum IconConfigKey: Hashable {
        
        case closeButton
        
        case iCloud
        case livePhoto
        
        case playButton
        case pauseButton
        case muteButton
        case unmuteButton
        
        func defaultValue() -> UIImage? {
            switch self {
            case .closeButton:
                return UIImage(systemName: "xmark")
            case .iCloud:
                return UIImage(systemName: "icloud")
            case .livePhoto:
                return UIImage(systemName: "livephoto")
            case .playButton:
                return UIImage(systemName: "play.fill")
            case .pauseButton:
                return UIImage(systemName: "pause.fill")
            case .muteButton:
                if #available(iOS 14.0, *) {
                    return UIImage(systemName: "speaker.wave.1.fill")
                } else {
                    return UIImage(systemName: "speaker.fill")
                }
            case .unmuteButton:
                return UIImage(systemName: "speaker.slash.fill")
            }
        }
    }
}

// MARK: - String
extension BrowserTheme {
    
    private func defaultStringValue(for key: StringConfigKey) -> String {
        return BundleHelper.localizedString(key: key.rawValue, module: .picker)
    }
}

extension StringConfigKey {
    
    public static let browserDownloadingFromiCloud = StringConfigKey(rawValue: "DOWNLOADING_FROM_ICLOUD")
    public static let browserFetchFailedPleaseRetry = StringConfigKey(rawValue: "FETCH_FAILED_PLEASE_RETRY")
}

// MARK: - Label
extension BrowserTheme {
    
    struct LabelConfigObject: Equatable {
        let key: LabelConfigKey
        let configuration: ((UILabel) -> Void)
        
        static func == (lhs: BrowserTheme.LabelConfigObject, rhs: BrowserTheme.LabelConfigObject) -> Bool {
            return lhs.key == rhs.key
        }
    }
    
    public enum LabelConfigKey: Hashable {

        case page
        case livePhotoMark
        case loadingFromiCloudTips
        case loadingFromiCloudProgress
    }
}

// MARK: - Button
extension BrowserTheme {
    
    struct ButtonConfigObject: Equatable {
        let key: ButtonConfigKey
        let configuration: ((UIButton) -> Void)
        
        static func == (lhs: BrowserTheme.ButtonConfigObject, rhs: BrowserTheme.ButtonConfigObject) -> Bool {
            return lhs.key == rhs.key
        }
    }
    
    public enum ButtonConfigKey: Hashable {
        
        case close
        
        case playPause
        /// mute and unmute
        case mute
        
        case reload
    }
}
