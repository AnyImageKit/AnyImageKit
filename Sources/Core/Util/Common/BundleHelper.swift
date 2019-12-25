//
//  BundleHelper.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

private class _BundleClass { }

struct BundleHelper {
    
    static var bundle = Bundle(for: _BundleClass.self)
    static private var _languageBundle: Bundle?
    
    static var languageBundle: Bundle? {
        if _languageBundle == nil {
            var language = Locale.preferredLanguages.first ?? "en"
            if language.hasPrefix("zh") {
                if language.contains("Hans") {
                    language = "zh-Hans"
                } else {
                    language = "zh-Hant"
                }
            }
            _languageBundle = Bundle(path: bundle.path(forResource: language, ofType: "lproj") ?? "")
        }
        return _languageBundle
    }
}

// MARK: - Styled Image
extension BundleHelper {
    
    static func image(named: String) -> UIImage? {
        return UIImage(named: named, in: bundle, compatibleWith: nil)
    }
    
    static func image(named: String, style: UserInterfaceStyle) -> UIImage? {
        let imageName: String
        switch style {
        case .auto:
            imageName = named + "Auto"
        case .light:
            imageName = named + "Light"
        case .dark:
            imageName = named + "Dark"
        }
        return UIImage(named: imageName, in: bundle, compatibleWith: nil)
    }
}

// MARK: - Localized String
extension BundleHelper {
    
    static func localizedString(key: String, value: String?, table: LocalizedTable) -> String {
        if let result = languageBundle?.localizedString(forKey: key, value: value, table: table.rawValue), result != key {
            return result
        } else if table != .default, let result = languageBundle?.localizedString(forKey: key, value: value, table: LocalizedTable.default.rawValue), result != key {
            return result
        }
        return Bundle.main.localizedString(forKey: key, value: value, table: nil)
    }
}

// MARK: - Localized Table
extension BundleHelper {
    
    struct LocalizedTable: RawRepresentable {
        
        let rawValue: String
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension BundleHelper.LocalizedTable {
    
    static let `default` = BundleHelper.LocalizedTable(rawValue: "Localizable")
}
