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
    
    static let `default` = ImageCache(name: "AnyImageKitImageCache")
    
    let module: CacheModule
    let path: String
    let workQueue: DispatchQueue
    let cache: ImageCache = ImageCacheTool.default
    
    init(module: CacheModule, path: String = "", memoryCountLimit: Int = 20) {
        self.module = module
        self.path = path.isEmpty ? module.path : path
        self.workQueue = DispatchQueue(label: "org.AnyImageKit.DispatchQueue.CacheTool.\(module.title).\(module.subTitle)")
        FileHelper.createDirectory(at: self.path)
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
        cache.store(image, forKey: path + key, toDisk: false)
    }
    
    /// 读取缓存
    /// - Parameters:
    ///   - key: 标识符
    func retrieveImage(forKey key: String) -> UIImage? {
        if let image = cache.retrieveImageInMemoryCache(forKey: path + key) {
            return image
        }
        return nil
    }
}
