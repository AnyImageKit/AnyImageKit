//
//  Picker+BundleHelper.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/12.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

extension BundleHelper {
    
    static func pickerLocalizedString(key: String) -> String {
        return localizedString(key: key, value: nil, table: .picker)
    }
}

extension BundleHelper.LocalizedTable {
    
    static let picker = BundleHelper.LocalizedTable(rawValue: "Picker")
}
