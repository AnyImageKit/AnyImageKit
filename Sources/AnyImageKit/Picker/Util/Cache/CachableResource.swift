//
//  CachableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/4.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

protocol CachableResource {
    
    var cacher: AnyImageCacher { get }
    var cahceIdentifier: String { get }
    func isCached(type: ImageResourceStorageType) -> Bool
    func removeCache(type: ImageResourceStorageType)
    func writeCache(storage: ImageResourceStorage, completion: @escaping ImageResourceLoadCompletion)
    func loadCache(type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion)
    func loadCacheURL(type: ImageResourceStorageType) -> URL
}

extension CachableResource {
    
    func isCached(type: ImageResourceStorageType) -> Bool {
        return cacher.isCached(key: cahceIdentifier, type: type)
    }
    
    func removeCache(type: ImageResourceStorageType) {
        cacher.remove(key: cahceIdentifier, type: type)
    }
    
    func writeCache(storage: ImageResourceStorage, completion: @escaping (Result<ImageResourceStorage, Error>) -> Void) {
        cacher.write(key: cahceIdentifier, storage: storage, completion: completion)
    }
    
    func loadCache(type: ImageResourceStorageType, completion: @escaping (Result<ImageResourceStorage, Error>) -> Void) {
        cacher.load(key: cahceIdentifier, type: type, completion: completion)
    }
    
    func loadCacheURL(type: ImageResourceStorageType) -> URL {
        cacher.loadURL(key: cahceIdentifier, type: type)
    }
}
