//
//  Editor+BundleHelper.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/12.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

extension BundleHelper {
    
    static func editorLocalizedString(key: String) -> String {
        return localizedString(key: key, value: nil, table: "Editor")
    }
}
