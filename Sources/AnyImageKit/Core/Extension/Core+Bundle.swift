//
//  Core+Bundle.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/9/23.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import Foundation

extension Bundle {
    
    #if !ANYIMAGEKIT_ENABLE_SPM
    private class _BundleClass { }
    #endif
    
    static var current: Bundle {
        #if ANYIMAGEKIT_ENABLE_SPM
        return Bundle.module
        #else
        return Bundle(for: _BundleClass.self)
        #endif
    }
}
