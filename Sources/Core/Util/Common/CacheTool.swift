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
    var memoryCountLimit: Int
    var useDiskCache: Bool
    var autoRemoveDiskCache: Bool
    
    init(module: CacheModule,
         memoryCountLimit: Int = 5,
         useDiskCache: Bool = false,
         autoRemoveDiskCache: Bool = false) {
        self.module = module
        self.memoryCountLimit = memoryCountLimit
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
    
    var path: String {
        let lib = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
        return "\(lib)/AnyImageKitCache/\(title)/\(subTitle)/"
    }
}

enum CacheModulePicker: String {
    case `default` = "Default"
}

enum CacheModuleEditor: String {
    case pen = "Pen"
    case mosaic = "Mosaic"
    case history = "History"
    case videoOutput = "VideoOutput"
}

final class CacheTool {
    
    private(set) var diskCacheList: [String] = []
    private var memory = NSCache<NSString, UIImage>()
    
    private let config: CacheConfig
    private let path: String
    private let queue: DispatchQueue
    
    init(config: CacheConfig, diskCacheList: [String] = []) {
        self.config = config
        self.diskCacheList = diskCacheList
        self.memory.countLimit = config.memoryCountLimit
        self.queue = DispatchQueue(label: "org.AnyImageProject.AnyImageKit.DispatchQueue.CacheTool.\(config.module.title).\(config.module.subTitle)")
        
        path = config.module.path
        FileHelper.createDirectory(at: path)
    }
    
    deinit {
        if config.autoRemoveDiskCache {
            diskCacheList.forEach { deleteDiskFile(identifier: $0 ) }
        }
    }
    
}

// MARK: - Public
extension CacheTool {
    
    func clearAll(memoryCache: Bool = true, diskCache: Bool = false) {
        if memoryCache {
            memory.removeAllObjects()
        }
        if diskCache {
            diskCacheList.forEach { deleteDiskFile(identifier: $0 ) }
            diskCacheList.removeAll()
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
            writeToFile(image, identifier: identifier)
        }
    }
    
    /// 读取缓存
    /// - Parameters:
    ///   - identifier: 标识符
    /// - Parameter deleteMemoryStorage: 读取缓存后删除内存缓存
    /// - Parameter deleteDiskStorage: 读取缓存后删除磁盘缓存
    func read(identifier: String, deleteMemoryStorage: Bool, deleteDiskStorage: Bool = false) -> UIImage? {
        if diskCacheList.isEmpty { return nil }
        if let idx = diskCacheList.firstIndex(of: identifier), deleteMemoryStorage {
            diskCacheList.remove(at: idx)
            loadDataFromFileIfNeeded()
        }
        if deleteDiskStorage {
            deleteDiskFile(identifier: identifier)
        }
        if let image = memory.object(forKey: identifier as NSString) {
            if deleteMemoryStorage {
                memory.removeObject(forKey: identifier as NSString)
            }
            return image
        }
        return readFromFile(identifier)
    }
    
    /// 读取缓存
    /// - Parameter deleteMemoryStorage: 读取缓存后删除内存缓存
    /// - Parameter deleteDiskStorage: 读取缓存后删除磁盘缓存
    func read(deleteMemoryStorage: Bool, deleteDiskStorage: Bool = false) -> UIImage? {
        var _identifier: String = ""
        if !diskCacheList.isEmpty && deleteMemoryStorage {
            _identifier = diskCacheList.removeLast()
            memory.removeObject(forKey: _identifier as NSString)
            loadDataFromFileIfNeeded()
        }
        if deleteDiskStorage && !_identifier.isEmpty {
            deleteDiskFile(identifier: _identifier)
        }
        
        if let identifier = diskCacheList.last {
            if let image = memory.object(forKey: identifier as NSString) {
                return image
            }
            return readFromFile(identifier)
        }
        return nil
    }
    
    /// 是否有磁盘缓存
    func hasDiskCache() -> Bool {
        return !diskCacheList.isEmpty
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
        guard diskCacheList.count - memory.countLimit + 1 >= 0 else { return }
        var identifier = ""
        for i in 0..<diskCacheList.count {
            let idx = diskCacheList.count-i-1
            identifier = diskCacheList[idx]
            if memory.object(forKey: identifier as NSString) != nil { continue }
        }
        if memory.object(forKey: identifier as NSString) != nil { return }
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let image = self.readFromFile(identifier) else { return }
            self.memory.setObject(image, forKey: identifier as NSString)
        }
    }
    
    /// 删除磁盘图片
    /// - Parameter identifier: 标识符
    private func deleteDiskFile(identifier: String) {
        let url = URL(fileURLWithPath: self.path + identifier)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            _print(error.localizedDescription)
        }
    }
}
