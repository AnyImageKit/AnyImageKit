//
//  CacheConfig.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/1.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import Foundation

struct CacheConfig {
    var module: CacheModule
    var memoryCountLimit: Int
    var useDiskCache: Bool
    var autoRemoveDiskCache: Bool
    
    init(module: CacheModule,
         memoryCountLimit: Int = 5,
         useDiskCache: Bool = false,
         autoRemoveDiskCache: Bool = false) {
        self.module = module
        self.memoryCountLimit = memoryCountLimit
        self.useDiskCache = useDiskCache
        self.autoRemoveDiskCache = autoRemoveDiskCache
    }
}
