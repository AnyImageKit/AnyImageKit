//
//  ImageCacheTool.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/1.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import Kingfisher

final class ImageCacheTool: CacheTool {
    
    private(set) var useDiskCache: Bool = false
    
    private lazy var cache: ImageCache = {
        do {
            return try ImageCache(name: "AnyImageKitImageCache", cacheDirectoryURL: URL(fileURLWithPath: path))
        } catch {
            return ImageCache.default
        }
    }()
    
    override init(module: CacheModule, path: String = "") {
        super.init(module: module, path: path)
        cache.memoryStorage.config.countLimit = 5
        cache.diskStorage.config.sizeLimit = 1024 * 1024 * 100 // Disk cache 100MB
    }
    
    convenience init(module: CacheModule, path: String = "", memoryCountLimit: Int = 5, useDiskCache: Bool = false) {
        self.init(module: module, path: path)
        self.useDiskCache = useDiskCache
        cache.memoryStorage.config.countLimit = memoryCountLimit
    }
}

extension ImageCacheTool {
    
    /// 删除所有缓存
    func clearAll() {
        cache.clearDiskCache()
        cache.clearMemoryCache()
    }
    
    /// 写入缓存
    /// - Parameters:
    ///   - image: 图片
    ///   - key: 标识符
    func store(_ image: UIImage, forKey key: String) {
        cache.store(image, forKey: key, toDisk: false)
        if useDiskCache {
            storeImageToDisk(image, forKey: key)
        }
    }
    
    /// 读取缓存
    /// - Parameters:
    ///   - key: 标识符
    func retrieveImage(forKey key: String) -> UIImage? {
        if let image = cache.retrieveImageInMemoryCache(forKey: key) {
            return image
        } else if useDiskCache {
            return retrieveImageInDisk(forKey: key)
        }
        return nil
    }
}

// MARK: - Private
extension ImageCacheTool {
    
    /// 将图片写入磁盘
    /// - Parameters:
    ///   - image: 图片
    ///   - key: 标识符
    private func storeImageToDisk(_ image: UIImage, forKey key: String) {
        guard let data = image.pngData() else { return }
        cache.storeToDisk(data, forKey: key)
    }
    
    /// 从磁盘读取图片
    /// - Parameter key: 标识符
    private func retrieveImageInDisk(forKey key: String) -> UIImage? {
        var image: UIImage? = nil
        let semaphore = DispatchSemaphore(value: 0)
        cache.retrieveImage(forKey: key) { (result) in
            switch result {
            case .success(let res):
                image = res.image
            case .failure(let error):
                _print(error)
            }
            semaphore.signal()
        }
        semaphore.wait()
        return image
    }
}
