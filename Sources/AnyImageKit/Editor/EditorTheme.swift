//
//  EditorTheme.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/7.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

/// UI Theme for Editor
public final class EditorTheme: ThemeConfigurable {
    
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
    
    public init() { }
    
    /// Set custom color
    public subscript(color key: ColorConfigKey) -> UIColor {
        get { colors[key] ?? key.defaultValue() }
        set { colors[key] = newValue }
    }
    
    /// Set custom icon
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
extension EditorTheme {
    
    public enum ColorConfigKey: Hashable {
        
        /// Main Color
        case primary
        
        func defaultValue() -> UIColor {
            switch self {
            case .primary:
                return Palette.primary
            }
        }
    }
}

// MARK: - Icon
extension EditorTheme {
    
    public enum IconConfigKey: String, Hashable {
        
        /// 25*25
        case checkMark = "CheckMark"
        /// 25*25
        case xMark = "XMark"
        /// 30*30
        case returnBackButton = "ReturnBackButton"
        
        /// 25*25
        case photoToolBrush = "PhotoToolBrush"
        /// 25*25
        case photoToolText = "PhotoToolText"
        /// 25*25
        case photoToolCrop = "PhotoToolCrop"
        /// 25*25
        case photoToolMosaic = "PhotoToolMosaic"
        /// 25*25
        case photoToolAdjust = "PhotoToolAdjust"
        /// 25*25
        case photoToolFilter = "PhotoToolFilter"
        
        /// 25*25
        case photoToolUndo = "PhotoToolUndo"
        /// 25*25
        case photoToolCropTrunLeft = "PhotoToolCropTrunLeft"
        /// 25*25
        case photoToolCropTrunRight = "PhotoToolCropTrunRight"
        /// 25*25
        case photoToolMosaicDefault = "PhotoToolMosaicDefault"
        
        /// 25*25
        case textNormalIcon = "TextNormalIcon"
        /// 25*25
        case trash = "Trash"
        
        /// Adjust 25*25
        
        case adjustExposure = "AdjustExposure"
        case adjustBrilliance = "AdjustBrilliance"
        case adjustHighlights = "AdjustHighlights"
        case adjustShadows = "AdjustShadows"
        case adjustContrast = "AdjustContrast"
        case adjustBrightness = "AdjustBrightness"
        case adjustBlackPoint = "AdjustBlackPoint"
        case adjustSaturation = "AdjustSaturation"
        case adjustVibrance = "AdjustVibrance"
        case adjustWarmth = "AdjustWarmth"
        case adjustTint = "AdjustTint"
        case adjustSharpness = "AdjustSharpness"
        case adjustDefinition = "AdjustDefinition"
        case adjustNoiseReduction = "AdjustNoiseReduction"
        case adjustVignette = "AdjustVignette"
        
        /// 20*50
        case videoCropLeft = "VideoCropLeft"
        /// 20*50
        case videoCropRight = "VideoCropRight"
        /// 30*30
        case videoPauseFill = "VideoPauseFill"
        /// 30*30
        case videoPlayFill = "VideoPlayFill"
        /// 30*30
        case videoToolVideo = "VideoToolVideo"
        
        func defaultValue() -> UIImage? {
            return BundleHelper.image(named: rawValue, module: .editor)
        }
    }
}

// MARK: - String
extension EditorTheme {
    
    private func defaultStringValue(for key: StringConfigKey) -> String {
        return BundleHelper.localizedString(key: key.rawValue, module: .editor)
    }
}

extension StringConfigKey {
    
    public static let editorBrush = StringConfigKey(rawValue: "BRUSH")
    public static let editorCrop = StringConfigKey(rawValue: "CROP")
    public static let editorMosaic = StringConfigKey(rawValue: "MOSAIC")
    public static let editorInputText = StringConfigKey(rawValue: "INPUT_TEXT")
    public static let editorAdjust = StringConfigKey(rawValue: "ADJUST")
    public static let editorFilter = StringConfigKey(rawValue: "FILTER")
    public static let editorFree = StringConfigKey(rawValue: "FREE")
    
    public static let editorDragHereToRemove = StringConfigKey(rawValue: "DRAG_HERE_TO_REMOVE")
    public static let editorReleaseToRemove = StringConfigKey(rawValue: "RELEASE_TO_REMOVE")
    
    public static let editorExposure = StringConfigKey(rawValue: "EXPOSURE")
    public static let editorBrilliance = StringConfigKey(rawValue: "BRILLIANCE")
    public static let editorHighlights = StringConfigKey(rawValue: "HIGHLIGHTS")
    public static let editorShadows = StringConfigKey(rawValue: "SHADOWS")
    public static let editorContrast = StringConfigKey(rawValue: "CONTRAST")
    public static let editorBrightness = StringConfigKey(rawValue: "BRIGHTNESS")
    public static let editorBlackPoint = StringConfigKey(rawValue: "BLACK_POINT")
    public static let editorSaturation = StringConfigKey(rawValue: "SATURATION")
    public static let editorVibrance = StringConfigKey(rawValue: "VIBRANCE")
    public static let editorWarmth = StringConfigKey(rawValue: "WARMTH")
    public static let editorTint = StringConfigKey(rawValue: "TINT")
    public static let editorSharpness = StringConfigKey(rawValue: "SHARPNESS")
    public static let editorDefinition = StringConfigKey(rawValue: "DEFINITION")
    public static let editorNoiseReduction = StringConfigKey(rawValue: "NOISE_REDUCTION")
    public static let editorVignette = StringConfigKey(rawValue: "VIGNETTE")
}

// MARK: - Label
extension EditorTheme {
    
    struct LabelConfigObject: Equatable {
        let key: LabelConfigKey
        let configuration: ((UILabel) -> Void)
        
        static func == (lhs: EditorTheme.LabelConfigObject, rhs: EditorTheme.LabelConfigObject) -> Bool {
            return lhs.key == rhs.key
        }
    }
    
    public enum LabelConfigKey: Hashable {
        
        case cropOption
        case trash
        case videoTimeline
    }
}

// MARK: - Button
extension EditorTheme {
    
    struct ButtonConfigObject: Equatable {
        let key: ButtonConfigKey
        let configuration: ((UIButton) -> Void)
        
        static func == (lhs: EditorTheme.ButtonConfigObject, rhs: EditorTheme.ButtonConfigObject) -> Bool {
            return lhs.key == rhs.key
        }
    }
    
    public enum ButtonConfigKey: Hashable {
        
        case back
        case cancel
        case done
        
        case photoOptions(EditorPhotoToolOption)
        case videoOptions(EditorVideoToolOption)
        
        case brush(EditorBrushColorOption)
        case mosaic(EditorMosaicStyleOption)
        case textColor(EditorTextColor)
        
        case undo
        case textSwitch
        
        case cropRotation
        case cropCancel
        case cropReset
        case cropDone
        
        case videoPlayPause
        case videoCropLeft
        case videoCropRight
    }
}
