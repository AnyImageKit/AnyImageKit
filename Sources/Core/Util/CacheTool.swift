//
//  CacheTool.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/6.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

struct CacheConfig {
    var module: CacheModule
    var limit: Int
    var useDiskCache: Bool
    var autoRemoveDiskCache: Bool
    
    init(module: CacheModule,
         limit: Int = 5,
         useDiskCache: Bool = false,
         autoRemoveDiskCache: Bool = false) {
        self.module = module
        self.limit = limit
        self.useDiskCache = useDiskCache
        self.autoRemoveDiskCache = autoRemoveDiskCache
    }
}

enum CacheModule {
    case picker(CacheModulePicker)
    case editor(CacheModuleEditor)
    
    var title: String {
        switch self {
        case .picker(_):
            return "Picker"
        case .editor(_):
            return "Editor"
        }
    }
    
    var subTitle: String {
        switch self {
        case .picker(let subModule):
            return subModule.rawValue
        case .editor(let subModule):
            return subModule.rawValue
        }
    }
}

enum CacheModulePicker: String {
    case `default` = "Default"
}

enum CacheModuleEditor: String {
    case pen = "Pen"
    case mosaic = "Mosaic"
}

final class CacheTool {
    
    private(set) var cacheList: [String] = []
    private var cache = NSCache<NSString, UIImage>()
    
    private let config: CacheConfig
    private let path: String
    private let queue: DispatchQueue
    
    init(config: CacheConfig, diskCacheList: [String] = []) {
        self.config = config
        self.cacheList = diskCacheList
        self.cache.countLimit = config.limit
        self.queue = DispatchQueue(label: "AnyImageKit.CacheTool.\(config.module.title).\(config.module.subTitle)")
        
        let lib = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
        path = "\(lib)/AnyImageKitCache/\(config.module.title)/\(config.module.subTitle)/"
        FileHelper.checkDirectory(path: path)
    }
    
    deinit {
        if config.autoRemoveDiskCache {
            for name in cacheList {
                deleteDiskFile(identifier: name)
            }
        }
    }
    
}

// MARK: - Public
extension CacheTool {
    
    /// 写入缓存
    /// - Parameters:
    ///   - image: 图片
    ///   - identifier: 标识符
    func write(_ image: UIImage, identifier: String = createIdentifier()) {
        cacheList.append(identifier)
        cache.setObject(image, forKey: identifier as NSString)
        if config.useDiskCache {
            writeToFile(image, identifier: identifier)
        }
    }
    
    /// 读取缓存
    /// - Parameters:
    ///   - identifier: 标识符
    ///   - delete: 读取缓存后删除缓存
    func read(identifier: String, delete: Bool) -> UIImage? {
        if cacheList.isEmpty { return nil }
        if let idx = cacheList.firstIndex(of: identifier), delete {
            cacheList.remove(at: idx)
            deleteDiskFile(identifier: identifier)
            loadDataFromFileIfNeeded()
        }
        if let image = cache.object(forKey: identifier as NSString) {
            if delete {
                cache.removeObject(forKey: identifier as NSString)
            }
            return image
        }
        return readFromFile(identifier)
    }
    
    /// 读取缓存
    /// - Parameter delete: 读取缓存后删除缓存
    func read(delete: Bool) -> UIImage? {
        if !cacheList.isEmpty && delete {
            let identifier = cacheList.removeLast()
            cache.removeObject(forKey: identifier as NSString)
            deleteDiskFile(identifier: identifier)
            loadDataFromFileIfNeeded()
        }
        if cacheList.isEmpty { return nil }
        let identifier = cacheList.last!
        if let image = cache.object(forKey: identifier as NSString) {
            return image
        }
        return readFromFile(identifier)
    }
    
    /// 是否有缓存
    func hasCache() -> Bool {
        return !cacheList.isEmpty
    }
    
}

// MARK: - Private
extension CacheTool {
    
    /// 创建缓存标识符
    static private func createIdentifier() -> String {
        let timestamp = Int(Date().timeIntervalSince1970*100)
        let random = (arc4random() % 8999) + 1000
        return "\(timestamp)_\(random)"
    }
    
    /// 将图片写入磁盘
    /// - Parameters:
    ///   - image: 图片
    ///   - identifier: 标识符
    private func writeToFile(_ image: UIImage, identifier: String) {
        if !config.useDiskCache { return }
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let data = image.pngData() else { return }
            let url = URL(fileURLWithPath: self.path + identifier)
            do {
                try data.write(to: url)
            } catch {
                _print(error.localizedDescription)
            }
        }
    }
    
    /// 从磁盘读取图片
    /// - Parameter identifier: 标识符
    private func readFromFile(_ identifier: String) -> UIImage? {
        if !config.useDiskCache { return nil }
        let url = URL(fileURLWithPath: path + identifier)
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            _print(error.localizedDescription)
        }
        return nil
    }
    
    /// 当内存缓存减少时，从磁盘中加载图片到内存
    private func loadDataFromFileIfNeeded() {
        if !config.useDiskCache { return }
        guard cacheList.count - cache.countLimit + 1 >= 0 else { return }
        var identifier = ""
        for i in 0..<cacheList.count {
            let idx = cacheList.count-i-1
            identifier = cacheList[idx]
            if cache.object(forKey: identifier as NSString) != nil { continue }
        }
        if cache.object(forKey: identifier as NSString) != nil { return }
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let image = self.readFromFile(identifier) else { return }
            self.cache.setObject(image, forKey: identifier as NSString)
        }
    }
    
    /// 删除磁盘图片
    /// - Parameter identifier: 标识符
    private func deleteDiskFile(identifier: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let url = URL(fileURLWithPath: self.path + identifier)
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                _print(error.localizedDescription)
            }
        }
    }
}
