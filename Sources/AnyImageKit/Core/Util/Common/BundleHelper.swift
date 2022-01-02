//
//  BundleHelper.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
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
            
        #if ANYIMAGEKIT_ENABLE_PICKER
        case .picker:
            return Bundle.anyImageKitPicker
        #endif
        
        #if ANYIMAGEKIT_ENABLE_EDITOR
        case .editor:
            return Bundle.anyImageKitEditor
        #endif
        
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        case .capture:
            return Bundle.anyImageKitCapture
        #endif
        }
        #endif
    }
}

// MARK: - Styled Image
extension BundleHelper {
    
    static func image(named: String, style: UserInterfaceStyle? = nil, module: Module) -> UIImage? {
        let nameStyled = styledName(named, style: style)
        return UIImage(named: nameStyled, in: bundle(for: module), compatibleWith: nil)
    }
    
    private static func styledName(_ named: String, style: UserInterfaceStyle?) -> String {
        switch style {
        case .auto:
            return named + "Auto"
        case .light:
            return named + "Light"
        case .dark:
            return named + "Dark"
        case .none:
            return named
        }
    }
}

// MARK: - Localized String
extension BundleHelper {
    
    static func localizedString(key: String, module: Module) -> String {
        return localizedString(key: key, value: nil, table: module.rawValue, bundle: bundle(for: module))
    }
    
    private static func localizedString(key: String, value: String?, table: String, bundle current: Bundle) -> String {
        let result = current.localizedString(forKey: key, value: value, table: table)
        if result != key {
            return result
        } else { // Just in case
            let coreBundle: Bundle
            if current != bundle(for: .core) {
                coreBundle = bundle(for: .core)
            } else {
                coreBundle = current
            }
            
            let coreResult = coreBundle.localizedString(forKey: key, value: value, table: Module.core.rawValue)
            if coreResult != key {
                return coreResult
            }
            return Bundle.main.localizedString(forKey: key, value: value, table: nil)
        }
    }
}
