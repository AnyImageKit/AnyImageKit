//
//  AnyImageCacher.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/10.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public typealias CacheResourceStorageCompletion = (Result<CachedResourceStorage, Error>) -> Void

public protocol AnyImageCacher {
    
    func isCached(key: String, type: CachedResourceStorageType) -> Bool
    func remove(key: String, type: CachedResourceStorageType)
    func write(key: String, storage: CachedResourceStorage, completion: @escaping CacheResourceStorageCompletion)
    func load(key: String, type: CachedResourceStorageType, completion: @escaping CacheResourceStorageCompletion)
    func loadURL(key: String, type: CachedResourceStorageType) -> URL
}
