//
//  CachableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/4.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import Kingfisher

public typealias AnyImageCacher = ImageCache

protocol CachableResource {
    
    var cacher: AnyImageCacher { get }
    var cahceIdentifier: String { get }
    func isCached(type: CachedResourceStorageType) -> Bool
    func removeCache(type: CachedResourceStorageType)
    func writeCache(storage: CachedResourceStorage, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void)
    func loadCache(type: CachedResourceStorageType, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void)
    func loadCacheURL(type: CachedResourceStorageType) -> URL
}

extension CachableResource {
    
    func isCached(type: CachedResourceStorageType) -> Bool {
        let processor = CachedResourceImageProcessor(type: type)
        return cacher.isCached(forKey: cahceIdentifier, processorIdentifier: processor.identifier)
    }
    
    func removeCache(type: CachedResourceStorageType) {
        let processor = CachedResourceImageProcessor(type: type)
        cacher.removeImage(forKey: cahceIdentifier, processorIdentifier: processor.identifier, fromMemory: true, fromDisk: true)
    }
    
    func writeCache(storage: CachedResourceStorage, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void) {
        let processor = CachedResourceImageProcessor(type: storage.type)
        var cacheSerializer = DefaultCacheSerializer()
        cacheSerializer.preferCacheOriginalData = true
        let options = KingfisherParsedOptionsInfo([.processor(processor),
                                                   .cacheSerializer(cacheSerializer)])
        switch storage {
        case .thumbnail(let image), .preview(let image):
            cacher.store(image, forKey: cahceIdentifier, options: options, toDisk: true) { result in
                switch result.diskCacheResult {
                case .success:
                    _print("✅ Cahce Write [\(storage.type.identifier)]<\(self.cahceIdentifier)>")
                    completion(.success(storage))
                case .failure(let error):
                    _print("❌ Cahce Write [\(storage.type.identifier)]<\(self.cahceIdentifier)>, error=\(error)")
                    completion(.failure(error))
                }
            }
        case .original(let image, let data):
            var cacheSerializer = DefaultCacheSerializer()
            cacheSerializer.preferCacheOriginalData = true
            cacher.store(image, original: data, forKey: cahceIdentifier, options: options, toDisk: true) { result in
                switch result.diskCacheResult {
                case .success:
                    _print("✅ Cahce Write [\(storage.type.identifier)]<\(self.cahceIdentifier)>")
                    completion(.success(storage))
                case .failure(let error):
                    _print("❌ Cahce Write [\(storage.type.identifier)]<\(self.cahceIdentifier)>, error=\(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func loadCache(type: CachedResourceStorageType, completion: @escaping (Result<CachedResourceStorage, Error>) -> Void) {
        let processor = CachedResourceImageProcessor(type: type)
        cacher.retrieveImage(forKey: cahceIdentifier, options: [.processor(processor)]) { result in
            switch result {
            case .success(let imageResult):
                switch imageResult {
                case .memory(let image):
                    _print("✅ Cahce Load [MEMORY] [\(type.identifier)]<\(self.cahceIdentifier)>")
                    completion(.success(.init(type: type, image: image, data: nil)))
                case .disk(let image):
                    _print("✅ Cahce Load [DISK] [\(type.identifier)]<\(self.cahceIdentifier)>")
                    completion(.success(.init(type: type, image: image, data: nil)))
                case .none:
                    _print("⚠️ Cahce Load [\(type.identifier)]<\(self.cahceIdentifier)>, Cahce not exist")
                    completion(.failure(AnyImageError.cacheNotExist))
                }
            case .failure(let error):
                _print("❌ Cahce Load [\(type.identifier)]<\(self.cahceIdentifier)>, error=\(error)")
                completion(.failure(error))
            }
        }
    }
    
    func loadCacheURL(type: CachedResourceStorageType) -> URL {
        let processor = CachedResourceImageProcessor(type: type)
        let path = cacher.cachePath(forKey: cahceIdentifier, processorIdentifier: processor.identifier)
        return URL(fileURLWithPath: path)
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
    
    var image: UIImage {
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
