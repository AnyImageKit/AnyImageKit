//
//  ImageCacheTool.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/1.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class ImageCacheTool: CacheTool {
    
    let memory = NSCache<NSString, UIImage>()
    
    override init(config: CacheConfig, diskCacheList: [String] = []) {
        super.init(config: config, diskCacheList: diskCacheList)
        self.memory.countLimit = config.memoryCountLimit
    }
}

extension ImageCacheTool {
    
    /// 删除所有缓存
    func clearAll(memoryCache: Bool = true, diskCache: Bool = false) {
        super.clearAll(diskCache: diskCache)
        if memoryCache {
            memory.removeAllObjects()
        }
    }
    
    /// 写入缓存
    /// - Parameters:
    ///   - image: 图片
    ///   - identifier: 标识符
    func write(_ image: UIImage, identifier: String = createIdentifier()) {
        diskCacheList.append(identifier)
        memory.setObject(image, forKey: identifier as NSString)
        if config.useDiskCache {
            writeImageToFile(image, identifier: identifier)
        }
    }
    
    /// 读取缓存
    /// - Parameters:
    ///   - identifier: 标识符
    ///   - deleteMemoryStorage: 读取缓存后删除内存缓存
    ///   - deleteDiskStorage: 读取缓存后删除磁盘缓存
    func read(identifier: String, deleteMemoryStorage: Bool, deleteDiskStorage: Bool = false) -> UIImage? {
        let image = readImageFromFile(identifier)
        if deleteDiskStorage {
            deleteDiskFile(identifier: identifier)
        }
        if deleteMemoryStorage {
            memory.removeObject(forKey: identifier as NSString)
        }
        return image
    }
}

// MARK: - Private
extension ImageCacheTool {
    
    /// 将图片写入磁盘
    /// - Parameters:
    ///   - image: 图片
    ///   - identifier: 标识符
    private func writeImageToFile(_ image: UIImage, identifier: String) {
        guard let data = image.pngData() else { return }
        super.writeToFile(data, identifier: identifier)
    }
    
    /// 从磁盘读取图片
    /// - Parameter identifier: 标识符
    private func readImageFromFile(_ identifier: String) -> UIImage? {
        guard let data = super.readFromFile(identifier) else { return nil }
        return UIImage(data: data)
    }
}
