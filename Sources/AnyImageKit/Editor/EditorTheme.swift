//
//  EditorTheme.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/7.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

/// UI Theme for Editor
public struct EditorTheme: Equatable {
    
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
extension EditorTheme {
    
    public enum ColorConfigKey: Hashable {
        
        /// Main Color
        case main
        
        func defaultValue() -> UIColor {
            switch self {
            case .main:
                return Palette.main
            }
        }
    }
}

// MARK: - Icon
extension EditorTheme {
    
    public enum IconConfigKey: Hashable {
        
        /// 20*20, Light/Dark
        case albumArrow
        
        func defaultValue() -> UIImage? {
            return nil
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
    public static let editorFree = StringConfigKey(rawValue: "FREE")
    
    public static let editorDragHereToRemove = StringConfigKey(rawValue: "DRAG_HERE_TO_REMOVE")
    public static let editorReleaseToRemove = StringConfigKey(rawValue: "RELEASE_TO_REMOVE")
}
