//
//  PickerTheme.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/2.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

/// UI Theme for Picker
public final class PickerTheme: ThemeConfigurable {

    /// User Interface Style
    public let style: UserInterfaceStyle
    
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
    
    public init(style: UserInterfaceStyle) {
        self.style = style
    }
    
    /// Set custom color
    /// - Note: Please set dynamic color if your app support dark mode
    public subscript(color key: ColorConfigKey) -> UIColor {
        get { colors[key] ?? key.defaultValue(for: style) }
        set { colors[key] = newValue }
    }
    
    /// Set custom icon
    /// - Note: Please set dynamic image if your app support dark mode
    public subscript(icon key: IconConfigKey) -> UIImage? {
        get { icons[key] ?? key.defaultValue(for: style) }
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
extension PickerTheme {
    
    public enum ColorConfigKey: Hashable {
        
        /// Primary Color
        case primary
        
        /// Text Color
        case text
        
        /// Sub Text Color
        case subText
        
        /// ToolBar Color
        case toolBar
        
        /// Background Color
        case background
        
        /// TableView Cell Selected Background Color
        case selectedCell
        
        /// Separator Line Color
        case separatorLine
        
        func defaultValue(for style: UserInterfaceStyle) -> UIColor {
            switch style {
            case .auto:
                switch self {
                case .primary: return UIColor.primaryColor
                case .text: return UIColor.primaryText
                case .subText: return UIColor.subText
                case .toolBar: return UIColor.toolBar
                case .background: return UIColor.background
                case .selectedCell: return UIColor.selectedCell
                case .separatorLine: return UIColor.separatorLine
                }
            case .light:
                switch self {
                case .primary: return UIColor.primaryColor
                case .text: return UIColor.primaryTextLight
                case .subText: return UIColor.subTextLight
                case .toolBar: return UIColor.toolBarLight
                case .background: return UIColor.backgroundLight
                case .selectedCell: return UIColor.selectedCellLight
                case .separatorLine: return UIColor.separatorLineLight
                }
            case .dark:
                switch self {
                case .primary: return UIColor.primaryColor
                case .text: return UIColor.primaryTextDark
                case .subText: return UIColor.subTextDark
                case .toolBar: return UIColor.toolBarDark
                case .background: return UIColor.backgroundDark
                case .selectedCell: return UIColor.selectedCellDark
                case .separatorLine: return UIColor.separatorLineDark
                }
            }
        }
    }
}

// MARK: - Icon
extension PickerTheme {
    
    public enum IconConfigKey: Hashable {
        
        /// 20*20, Light/Dark
        case albumArrow
        
        /// 20*20, Light/Dark
        case arrowRight
        
        /// 50*50
        case camera
        
        /// 16*16
        case checkOff
        
        /// 16*16, Template
        case checkOn
        
        /// 20*20
        case iCloud
        
        /// 20*20, Light/Dark
        case livePhoto
        
        /// 20*20
        case photoEdited
        
        /// 24*24, Light/Dark
        case pickerCircle
        
        /// 14*24, Light/Dark
        case returnButton
        
        /// 24*15
        case video
        
        /// 80*80
        case videoPlay
        
        /// 20*20, Light/Dark
        case warning
        
        func defaultValue(for style: UserInterfaceStyle) -> UIImage? {
            switch self {
            case .albumArrow:
                return BundleHelper.image(named: "AlbumArrow", style: style, module: .picker)
            case .arrowRight:
                return BundleHelper.image(named: "ArrowRight", style: style, module: .picker)
            case .camera:
                return BundleHelper.image(named: "Camera", module: .picker)
            case .checkOff:
                return BundleHelper.image(named: "CheckOff", module: .picker)
            case .checkOn:
                return BundleHelper.image(named: "CheckOn", module: .picker)?.withRenderingMode(.alwaysTemplate)
            case .iCloud:
                return BundleHelper.image(named: "iCloud", module: .picker)
            case .livePhoto:
                return BundleHelper.image(named: "LivePhoto", style: style, module: .picker)
            case .photoEdited:
                return BundleHelper.image(named: "PhotoEdited", module: .picker)
            case .pickerCircle:
                return BundleHelper.image(named: "PickerCircle", style: style, module: .picker)
            case .returnButton:
                return BundleHelper.image(named: "ReturnButton", style: style, module: .picker)
            case .video:
                return BundleHelper.image(named: "Video", module: .picker)
            case .videoPlay:
                return BundleHelper.image(named: "VideoPlay", module: .picker)
            case .warning:
                return BundleHelper.image(named: "Warning", style: style, module: .picker)
            }
        }
    }
}

// MARK: - String
extension PickerTheme {
    
    private func defaultStringValue(for key: StringConfigKey) -> String {
        return BundleHelper.localizedString(key: key.rawValue, module: .picker)
    }
}

extension StringConfigKey {
    
    public static let pickerOriginalImage = StringConfigKey(rawValue: "ORIGINAL_IMAGE")
    public static let pickerSelectPhoto = StringConfigKey(rawValue: "SELECT_PHOTO")
    public static let pickerUnselectPhoto = StringConfigKey(rawValue: "UNSELECT_PHOTO")
    public static let pickerTakePhoto = StringConfigKey(rawValue: "TAKE_PHOTO")
    public static let pickerSelectMaximumOfPhotos = StringConfigKey(rawValue: "SELECT_A_MAXIMUM_OF_PHOTOS")
    public static let pickerSelectMaximumOfVideos = StringConfigKey(rawValue: "SELECT_A_MAXIMUM_OF_VIDEOS")
    public static let pickerSelectMaximumOfPhotosOrVideos = StringConfigKey(rawValue: "SELECT_A_MAXIMUM_OF_PHOTOS_OR_VIDEOS")
    public static let pickerDownloadingFromiCloud = StringConfigKey(rawValue: "DOWNLOADING_FROM_ICLOUD")
    public static let pickerFetchFailedPleaseRetry = StringConfigKey(rawValue: "FETCH_FAILED_PLEASE_RETRY")
    public static let pickerA11ySwitchAlbumTips = StringConfigKey(rawValue: "A11Y_SWITCH_ALBUM_TIPS")
    public static let pickerLimitedPhotosPermissionTips = StringConfigKey(rawValue: "LIMITED_PHOTOS_PERMISSION_TIPS")
}

// MARK: - Label
extension PickerTheme {
    
    struct LabelConfigObject: Equatable {
        let key: LabelConfigKey
        let configuration: ((UILabel) -> Void)
        
        static func == (lhs: PickerTheme.LabelConfigObject, rhs: PickerTheme.LabelConfigObject) -> Bool {
            return lhs.key == rhs.key
        }
    }
    
    public enum LabelConfigKey: Hashable {
        
        case permissionLimitedTips
        case permissionDeniedTips
        
        case albumTitle
        case albumCellTitle
        case albumCellSubTitle
        
        case assetCellVideoDuration
        case assetCellGIFMark
        
        case selectedNumber
        case selectedNumberInPreview
        
        case livePhotoMark
        case loadingFromiCloudTips
        case loadingFromiCloudProgress
    }
}

// MARK: - Button
extension PickerTheme {
    
    struct ButtonConfigObject: Equatable {
        let key: ButtonConfigKey
        let configuration: ((UIButton) -> Void)
        
        static func == (lhs: PickerTheme.ButtonConfigObject, rhs: PickerTheme.ButtonConfigObject) -> Bool {
            return lhs.key == rhs.key
        }
    }
    
    public enum ButtonConfigKey: Hashable {
        
        case preview
        case edit
        case originalImage
        case done
        case backInPreview
        case goSettings
    }
}
