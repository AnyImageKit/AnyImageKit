//
//  CachableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/4.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol CachableResource {
    
    var cacher: AnyImageCacher { get }
    var cahceIdentifier: String { get }
    func isCached(type: CachedResourceStorageType) -> Bool
    func removeCache(type: CachedResourceStorageType)
    func writeCache(storage: CachedResourceStorage, completion: @escaping CacheResourceStorageCompletion)
    func loadCache(type: CachedResourceStorageType, completion: @escaping CacheResourceStorageCompletion)
    func loadCacheURL(type: CachedResourceStorageType) -> URL
}

extension CachableResource {
    
    func isCached(type: CachedResourceStorageType) -> Bool {
        return cacher.isCached(key: cahceIdentifier, type: type)
    }
    
    func removeCache(type: CachedResourceStorageType) {
        cacher.remove(key: cahceIdentifier, type: type)
    }
    
    func writeCache(storage: CachedResourceStorage, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void) {
        cacher.write(key: cahceIdentifier, storage: storage, completion: completion)
    }
    
    func loadCache(type: CachedResourceStorageType, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void) {
        cacher.load(key: cahceIdentifier, type: type, completion: completion)
    }
    
    func loadCacheURL(type: CachedResourceStorageType) -> URL {
        cacher.loadURL(key: cahceIdentifier, type: type)
    }
}

public enum CachedResourceStorageType: IdentifiableResource {
    
    case thumbnail
    case preview
    case original
    
    public var identifier: String {
        switch self {
        case .thumbnail:
            return "THUMBNAIL"
        case .preview:
            return "PREVIEW"
        case .original:
            return "ORIGINAL"
        }
    }
}

public enum CachedResourceStorage {
    
    case thumbnail(UIImage)
    case preview(UIImage)
    case original(UIImage, Data?)
    
    init(type: CachedResourceStorageType, image: UIImage, data: Data?) {
        switch type {
        case .thumbnail:
            self = .thumbnail(image)
        case .preview:
            self = .preview(image)
        case .original:
            self = .original(image, data)
        }
    }
    
    public var type: CachedResourceStorageType {
        switch self {
        case .thumbnail:
            return .thumbnail
        case .preview:
            return .preview
        case .original:
            return .original
        }
    }
    
    public var image: UIImage {
        switch self {
        case .thumbnail(let image):
            return image
        case .preview(let image):
            return image
        case .original(let image, _):
            return image
        }
    }
}
