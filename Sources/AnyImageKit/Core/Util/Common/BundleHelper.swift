//
//  BundleHelper.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

struct BundleHelper {
    
    static var appName: String {
        if let info = Bundle.main.localizedInfoDictionary {
            if let appName = info["CFBundleDisplayName"] as? String { return appName }
            if let appName = info["CFBundleName"] as? String { return appName }
            if let appName = info["CFBundleExecutable"] as? String { return appName }
        }
        
        if let info = Bundle.main.infoDictionary {
            if let appName = info["CFBundleDisplayName"] as? String { return appName }
            if let appName = info["CFBundleName"] as? String { return appName }
            if let appName = info["CFBundleExecutable"] as? String { return appName }
        }
        return ""
    }
}

// MARK: - Module
extension BundleHelper {
    
    enum Module: String, Equatable {
        
        case core = "Core"
        
        #if ANYIMAGEKIT_ENABLE_PICKER
        case picker = "Picker"
        #endif
        
        #if ANYIMAGEKIT_ENABLE_EDITOR
        case editor = "Editor"
        #endif
        
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        case capture = "Capture"
        #endif
    }
    
    static func bundle(for module: Module) -> Bundle {
        #if ANYIMAGEKIT_ENABLE_SPM
        return Bundle.module
        #else
        switch module {
        case .core:
            return Bundle.anyImageKitCore
        case .picker:
            return Bundle.anyImageKitPicker
        case .editor:
            return Bundle.anyImageKitEditor
        case .capture:
            return Bundle.anyImageKitCapture
        }
        #endif
    }
}

// MARK: - Styled Image
extension BundleHelper {
    
    private static func image(named: String, bundle: Bundle) -> UIImage? {
        return UIImage(named: named, in: bundle, compatibleWith: nil)
    }
    
    static func image(named: String, module: Module) -> UIImage? {
        return UIImage(named: named, in: bundle(for: module), compatibleWith: nil)
    }
    
    static func image(named: String, style: UserInterfaceStyle, module: Module) -> UIImage? {
        let imageName = styledName(named, style: style)
        return image(named: imageName, module: module)
    }
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    static func editorImage(named: String) -> UIImage? {
        #if ANYIMAGEKIT_ENABLE_SPM
        return image(named: named, bundle: .module)
        #else
        return image(named: named, bundle: .anyImageKitEditor)
        #endif
    }
    #endif
    
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    static func captureImage(named: String) -> UIImage? {
        #if ANYIMAGEKIT_ENABLE_SPM
        return image(named: named, bundle: .module)
        #else
        return image(named: named, bundle: .anyImageKitCapture)
        #endif
    }
    #endif
    
    private static func styledName(_ named: String, style: UserInterfaceStyle) -> String {
        switch style {
        case .auto:
            return named + "Auto"
        case .light:
            return named + "Light"
        case .dark:
            return named + "Dark"
        }
    }
    
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    static func editorImage(named: String, style: UserInterfaceStyle) -> UIImage? {
        let imageName = styledName(named, style: style)
        return editorImage(named: imageName)
    }
    #endif
    
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    static func captureImage(named: String, style: UserInterfaceStyle) -> UIImage? {
        let imageName = styledName(named, style: style)
        return captureImage(named: imageName)
    }
    #endif
}

// MARK: - Localized String
extension BundleHelper {
    
    private static func localizedString(key: String, value: String?, table: String, bundle: Bundle) -> String {
        let result = bundle.localizedString(forKey: key, value: value, table: table)
        if result != key {
            return result
        } else {
            return Bundle.main.localizedString(forKey: key, value: value, table: nil)
        }
    }
    
    static func coreLocalizedString(key: String) -> String {
        #if ANYIMAGEKIT_ENABLE_SPM
        return localizedString(key: key, value: nil, table: "Core", bundle: .module)
        #else
        return localizedString(key: key, value: nil, table: "Core", bundle: .anyImageKitCore)
        #endif
    }
    
    #if ANYIMAGEKIT_ENABLE_PICKER
    static func pickerLocalizedString(key: String) -> String {
        #if ANYIMAGEKIT_ENABLE_SPM
        return localizedString(key: key, value: nil, table: "Picker", bundle: .module)
        #else
        return localizedString(key: key, value: nil, table: "Picker", bundle: .anyImageKitPicker)
        #endif
    }
    #endif
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    static func editorLocalizedString(key: String) -> String {
        #if ANYIMAGEKIT_ENABLE_SPM
        return localizedString(key: key, value: nil, table: "Editor", bundle: .module)
        #else
        return localizedString(key: key, value: nil, table: "Editor", bundle: .anyImageKitEditor)
        #endif
    }
    #endif
    
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    static func captureLocalizedString(key: String) -> String {
        #if ANYIMAGEKIT_ENABLE_SPM
        return localizedString(key: key, value: nil, table: "Capture", bundle: .module)
        #else
        return localizedString(key: key, value: nil, table: "Capture", bundle: .anyImageKitCapture)
        #endif
    }
    #endif
}
