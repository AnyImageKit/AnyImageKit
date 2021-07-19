//
//  CachableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/4.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

protocol CachableResource: IdentifiableResource {
    
    var cacher: AnyImageCacher { get }
    func isCached(type: ImageResourceStorageType) -> Bool
    func cacheRemove(type: ImageResourceStorageType)
    func cacheWrite(storage: ImageResourceStorage, completion: @escaping ImageResourceLoadCompletion)
    func cacheRead(type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion)
    func cacheReadURL(type: ImageResourceStorageType) -> URL
}

extension CachableResource {
    
    func isCached(type: ImageResourceStorageType) -> Bool {
        return cacher.isCached(key: identifier, type: type)
    }
    
    func cacheRemove(type: ImageResourceStorageType) {
        cacher.remove(key: identifier, type: type)
    }
    
    func cacheWrite(storage: ImageResourceStorage, completion: @escaping (Result<ImageResourceStorage, Error>) -> Void) {
        cacher.write(key: identifier, storage: storage, completion: completion)
    }
    
    func cacheRead(type: ImageResourceStorageType, completion: @escaping (Result<ImageResourceStorage, Error>) -> Void) {
        cacher.read(key: identifier, type: type, completion: completion)
    }
    
    func cacheReadURL(type: ImageResourceStorageType) -> URL {
        cacher.readURL(key: identifier, type: type)
    }
}
