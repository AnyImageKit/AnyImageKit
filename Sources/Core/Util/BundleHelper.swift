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
            var language = (Locale.preferredLanguages.first ?? "en") as NSString
            if language.hasPrefix("zh") {
                if language.range(of: "Hans").location != NSNotFound {
                    language = "zh-Hans"
                } else {
                    language = "zh-Hant"
                }
            }
            _languageBundle = Bundle(path: bundle.path(forResource: language as String, ofType: "lproj") ?? "")
        }
        return _languageBundle
    }
    
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
    
    static func localizedString(key: String) -> String {
        return localizedString(key: key, value: nil, table: nil)
    }
    
    static func localizedString(key: String, value: String?, table: String?) -> String {
        var value = value
        value = languageBundle?.localizedString(forKey: key, value: value, table: table)
        return Bundle.main.localizedString(forKey: key, value: value, table: table)
    }
}
