//
//  AnyImageCacher+Kingfisher.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/11.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Kingfisher

struct KFBasedMixCacher: AnyImageCacher {
    
    static let `default` = KFBasedMixCacher(imageCache: .default)
    
    private let imageCache: Kingfisher.ImageCache
    
    init(imageCache: Kingfisher.ImageCache) {
        self.imageCache = imageCache
    }
    
    func isCached(key: String, type: CachedResourceStorageType) -> Bool {
        let processor = CachedResourceImageProcessor(type: type)
        return imageCache.isCached(forKey: key, processorIdentifier: processor.identifier)
    }
    
    func remove(key: String, type: CachedResourceStorageType) {
        let processor = CachedResourceImageProcessor(type: type)
        imageCache.removeImage(forKey: key, processorIdentifier: processor.identifier, fromMemory: true, fromDisk: true)
    }
    
    func write(key: String, storage: CachedResourceStorage, completion: @escaping CacheResourceStorageCompletion) {
        let processor = CachedResourceImageProcessor(type: storage.type)
        var cacheSerializer = DefaultCacheSerializer()
        cacheSerializer.preferCacheOriginalData = true
        let options = KingfisherParsedOptionsInfo([.processor(processor),
                                                   .cacheSerializer(cacheSerializer)])
        switch storage {
        case .thumbnail(let image), .preview(let image):
            imageCache.store(image, forKey: key, options: options, toDisk: true) { result in
                switch result.diskCacheResult {
                case .success:
                    _print("✅ Cahce Write [\(storage.type.identifier)]<\(key)>")
                    completion(.success(storage))
                case .failure(let error):
                    _print("❌ Cahce Write [\(storage.type.identifier)]<\(key)>, error=\(error)")
                    completion(.failure(error))
                }
            }
        case .original(let image, let data):
            var cacheSerializer = DefaultCacheSerializer()
            cacheSerializer.preferCacheOriginalData = true
            imageCache.store(image, original: data, forKey: key, options: options, toDisk: true) { result in
                switch result.diskCacheResult {
                case .success:
                    _print("✅ Cahce Write [\(storage.type.identifier)]<\(key)>")
                    completion(.success(storage))
                case .failure(let error):
                    _print("❌ Cahce Write [\(storage.type.identifier)]<\(key)>, error=\(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func load(key: String, type: CachedResourceStorageType, completion: @escaping CacheResourceStorageCompletion) {
        let processor = CachedResourceImageProcessor(type: type)
        imageCache.retrieveImage(forKey: key, options: [.processor(processor)]) { result in
            switch result {
            case .success(let imageResult):
                switch imageResult {
                case .memory(let image):
                    _print("✅ Cahce Load [MEMORY] [\(type.identifier)]<\(key)>")
                    completion(.success(.init(type: type, image: image, data: nil)))
                case .disk(let image):
                    _print("✅ Cahce Load [DISK] [\(type.identifier)]<\(key)>")
                    completion(.success(.init(type: type, image: image, data: nil)))
                case .none:
                    _print("⚠️ Cahce Load [\(type.identifier)]<\(key)>, Cahce not exist")
                    completion(.failure(AnyImageError.cacheNotExist))
                }
            case .failure(let error):
                _print("❌ Cahce Load [\(type.identifier)]<\(key)>, error=\(error)")
                completion(.failure(error))
            }
        }
    }
    
    func loadURL(key: String, type: CachedResourceStorageType) -> URL {
        let processor = CachedResourceImageProcessor(type: type)
        let path = imageCache.cachePath(forKey: key, processorIdentifier: processor.identifier)
        return URL(fileURLWithPath: path)
    }
}

extension KFBasedMixCacher {
    
    private struct CachedResourceImageProcessor: ImageProcessor {
        
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
}
