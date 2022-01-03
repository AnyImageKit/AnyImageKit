//
//  ImageCacheTool.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/1.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Kingfisher

struct ImageCacheTool: Cacheable {
    
    let module: CacheModule
    let path: String
    let workQueue: DispatchQueue
    let useDiskCache: Bool
    let cache: ImageCache
    
    init(module: CacheModule, path: String = "", memoryCountLimit: Int = 5, useDiskCache: Bool = false) {
        self.module = module
        self.path = path.isEmpty ? module.path : path
        self.workQueue = DispatchQueue(label: "org.AnyImageKit.DispatchQueue.CacheTool.\(module.title).\(module.subTitle)")
        self.useDiskCache = useDiskCache
        do {
            self.cache = try ImageCache(name: "AnyImageKitImageCache", cacheDirectoryURL: URL(fileURLWithPath: self.path))
        } catch {
            self.cache = ImageCache.default
        }
        FileHelper.createDirectory(at: self.path)
        cache.memoryStorage.config.countLimit = memoryCountLimit
        cache.diskStorage.config.sizeLimit = 1024 * 1024 * 100 // Disk cache 100MB
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
