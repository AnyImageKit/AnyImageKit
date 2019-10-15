//
//  BundleHelper.swift
//  AnyImagePicker
//
//  Created by 蒋惠 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit

struct BundleHelper {
    
    static var bundle = Bundle(for: ImagePickerController.self)
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
    
    static func image(named: String, style: ImagePickerController.UserInterfaceStyle) -> UIImage? {
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
        return localizedString(key: key, value: nil)
    }
    
    static func localizedString(key: String, value: String?) -> String {
        var value = value
        value = languageBundle?.localizedString(forKey: key, value: value, table: nil)
        return Bundle.main.localizedString(forKey: key, value: value, table: nil)
    }
}
