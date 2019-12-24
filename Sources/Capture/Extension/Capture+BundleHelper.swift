//
//  Capture+BundleHelper.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/24.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

extension BundleHelper {
    
    static func captureLocalizedString(key: String) -> String {
        return localizedString(key: key, value: nil, table: .capture)
    }
}

extension BundleHelper.Table {
    
    static let capture = BundleHelper.Table(rawValue: "Capture")
}
