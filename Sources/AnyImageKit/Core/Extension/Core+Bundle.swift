//
//  Core+Bundle.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/9/23.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Foundation

extension Bundle {
    
    #if !ANYIMAGEKIT_ENABLE_SPM
    private class _BundleClass { }
    
    static let anyImageKitCore: Bundle = {
        let bundle = Bundle(for: _BundleClass.self)
        guard let url = bundle.url(forResource: "AnyImageKit_Core", withExtension: "bundle"), let resource = Bundle(url: url) else {
            return bundle
        }
        return resource
    }()
    
    #if ANYIMAGEKIT_ENABLE_PICKER
    static let anyImageKitPicker: Bundle = {
        let bundle = Bundle(for: _BundleClass.self)
        guard let url = bundle.url(forResource: "AnyImageKit_Picker", withExtension: "bundle"), let resource = Bundle(url: url) else {
            return bundle
        }
        return resource
    }()
    #endif
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    static let anyImageKitEditor: Bundle = {
        let bundle = Bundle(for: _BundleClass.self)
        guard let url = bundle.url(forResource: "AnyImageKit_Editor", withExtension: "bundle"), let resource = Bundle(url: url) else {
            return bundle
        }
        return resource
    }()
    #endif
    
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    static let anyImageKitCapture: Bundle = {
        let bundle = Bundle(for: _BundleClass.self)
        guard let url = bundle.url(forResource: "AnyImageKit_Capture", withExtension: "bundle"), let core = Bundle(url: url) else {
            return bundle
        }
        return core
    }()
    #endif
    
    #endif
    
    static var current: Bundle {
        #if ANYIMAGEKIT_ENABLE_SPM
        return Bundle.module
        #else
        return Bundle(for: _BundleClass.self)
        #endif
    }
}
