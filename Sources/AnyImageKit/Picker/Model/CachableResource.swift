//
//  CachableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/4.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation
import Kingfisher

protocol CachableResource: IdentifiableResource {
    
    var cache: ImageCache { get }
    func isCached(mode: CachedResourceStoreMode) -> Bool
    func removeCache(mode: CachedResourceStoreMode)
    func writeCache(storage: CachedResourceStorage, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void)
    func loadCache(mode: CachedResourceStoreMode, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void)
    func loadCacheURL(mode: CachedResourceStoreMode, completion: @escaping (Result<URL, Error>) -> Void)
}

extension CachableResource {
    
    func isCached(mode: CachedResourceStoreMode) -> Bool {
        let processor = CachedResourceImageProcessor(mode: mode)
        return cache.isCached(forKey: identifier, processorIdentifier: processor.identifier)
    }
    
    func removeCache(mode: CachedResourceStoreMode) {
        let processor = CachedResourceImageProcessor(mode: mode)
        cache.removeImage(forKey: identifier, processorIdentifier: processor.identifier, fromMemory: true, fromDisk: true)
    }
    
    func writeCache(storage: CachedResourceStorage, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void) {
        let processor = CachedResourceImageProcessor(mode: storage.mode)
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
    
    func loadCache(mode: CachedResourceStoreMode, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void) {
        let processor = CachedResourceImageProcessor(mode: mode)
        cache.retrieveImage(forKey: identifier, options: [.processor(processor)]) { result in
            switch result {
            case .success(let imageResult):
                switch imageResult {
                case .memory(let image), .disk(let image):
                    completion(.success(.init(mode: mode, image: image, data: nil)))
                case .none:
                    completion(.failure(AnyImageError.cacheNotExist))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadCacheURL(mode: CachedResourceStoreMode, completion: @escaping (Result<URL, Error>) -> Void) {
        
    }
}

enum CachedResourceStoreMode {
    
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
        return mode.identifier
    }
    
    let mode: CachedResourceStoreMode
    
    init(mode: CachedResourceStoreMode) {
        self.mode = mode
    }
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        DefaultImageProcessor.default.process(item: item, options: options)
    }
}

enum CachedResourceStorage {
    
    case thumbnail(UIImage)
    case preview(UIImage)
    case original(UIImage, Data?)
    
    init(mode: CachedResourceStoreMode, image: UIImage, data: Data?) {
        switch mode {
        case .thumbnail:
            self = .thumbnail(image)
        case .preview:
            self = .preview(image)
        case .original:
            self = .original(image, data)
        }
    }
    
    var mode: CachedResourceStoreMode {
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
