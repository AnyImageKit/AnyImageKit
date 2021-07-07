//
//  CachableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/4.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import Kingfisher

protocol CachableResource: IdentifiableResource {
    
    var cache: ImageCache { get }
    func isCached(type: CachedResourceStorageType) -> Bool
    func removeCache(type: CachedResourceStorageType)
    func writeCache(storage: CachedResourceStorage, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void)
    func loadCache(type: CachedResourceStorageType, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void)
    func loadCacheURL(type: CachedResourceStorageType) -> URL
}

extension CachableResource {
    
    func isCached(type: CachedResourceStorageType) -> Bool {
        let processor = CachedResourceImageProcessor(type: type)
        return cache.isCached(forKey: identifier, processorIdentifier: processor.identifier)
    }
    
    func removeCache(type: CachedResourceStorageType) {
        let processor = CachedResourceImageProcessor(type: type)
        cache.removeImage(forKey: identifier, processorIdentifier: processor.identifier, fromMemory: true, fromDisk: true)
    }
    
    func writeCache(storage: CachedResourceStorage, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void) {
        let processor = CachedResourceImageProcessor(type: storage.type)
        var cacheSerializer = DefaultCacheSerializer()
        cacheSerializer.preferCacheOriginalData = true
        let options = KingfisherParsedOptionsInfo([.processor(processor),
                                                   .cacheSerializer(cacheSerializer)])
        switch storage {
        case .thumbnail(let image), .preview(let image):
            cache.store(image, forKey: identifier, options: options, toDisk: true) { result in
                switch result.diskCacheResult {
                case .success:
                    completion(.success(storage))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .original(let image, let data):
            var cacheSerializer = DefaultCacheSerializer()
            cacheSerializer.preferCacheOriginalData = true
            cache.store(image, original: data, forKey: identifier, options: options, toDisk: true) { result in
                switch result.diskCacheResult {
                case .success:
                    completion(.success(storage))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func loadCache(type: CachedResourceStorageType, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void) {
        let processor = CachedResourceImageProcessor(type: type)
        cache.retrieveImage(forKey: identifier, options: [.processor(processor)]) { result in
            switch result {
            case .success(let imageResult):
                switch imageResult {
                case .memory(let image), .disk(let image):
                    completion(.success(.init(type: type, image: image, data: nil)))
                case .none:
                    completion(.failure(AnyImageError.cacheNotExist))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadCacheURL(type: CachedResourceStorageType) -> URL {
            let processor = CachedResourceImageProcessor(type: type)
            let path = cache.cachePath(forKey: identifier, processorIdentifier: processor.identifier)
            return URL(fileURLWithPath: path)
        }
}

enum CachedResourceStorageType {
    
    case thumbnail
    case preview
    case original
    
    var identifier: String {
        switch self {
        case .thumbnail:
            return "thumbnail"
        case .preview:
            return "preview"
        case .original:
            return "original"
        }
    }
}

struct CachedResourceImageProcessor: ImageProcessor {
    
    var identifier: String {
        return type.identifier
    }
    
    let type: CachedResourceStorageType
    
    init(type: CachedResourceStorageType) {
        self.type = type
    }
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        DefaultImageProcessor.default.process(item: item, options: options)
    }
}

enum CachedResourceStorage {
    
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
    
    var type: CachedResourceStorageType {
        switch self {
        case .thumbnail:
            return .thumbnail
        case .preview:
            return .preview
        case .original:
            return .original
        }
    }
}
