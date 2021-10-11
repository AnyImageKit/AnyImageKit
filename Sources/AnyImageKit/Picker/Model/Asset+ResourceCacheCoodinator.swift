//
//  Asset+ResourceCacheCoodinator.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/25.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

extension Asset: ResourceCacheCoodinator {
    
    func isCached(type: ImageResourceStorageType) -> Bool {
        return cacher.isCached(key: identifier, type: type)
    }
    
    func cacheRemove(type: ImageResourceStorageType) {
        cacher.remove(key: identifier, type: type)
    }
    
    func cacheWrite(storage: ImageResourceStorage, completion: @escaping ImageResourceLoadCompletion) {
        cacher.write(key: identifier, storage: storage, completion: completion)
    }
    
    func cacheRead(type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion) {
        cacher.read(key: identifier, type: type, completion: completion)
    }
    
    func cacheReadURL(type: ImageResourceStorageType) -> URL {
        cacher.readURL(key: identifier, type: type)
    }
}
