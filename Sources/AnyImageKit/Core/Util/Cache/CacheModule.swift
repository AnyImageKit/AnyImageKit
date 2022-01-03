//
//  CacheModule.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/1.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

enum CacheModule {
    
    case picker(CacheModulePicker)
    case editor(CacheModuleEditor)
}

enum CacheModulePicker: String {
    
    case `default` = "Default"
}

enum CacheModuleEditor: String {

    case `default` = "Default"
    case bezierPath = "BezierPath"
}

extension CacheModule {
    
    var title: String {
        switch self {
        case .picker:
            return "Picker"
        case .editor:
            return "Editor"
        }
    }
    
    var subTitle: String {
        switch self {
        case .picker(let subModule):
            return subModule.rawValue
        case .editor(let subModule):
            return subModule.rawValue
        }
    }
    
    var path: String {
        let lib = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
        return "\(lib)/AnyImageKitCache/\(title)/\(subTitle)/"
    }
}

extension CacheModuleEditor {
    
    static var imageModule: [CacheModuleEditor] {
        return [.default, .bezierPath]
    }
}
