//
//  CacheTool.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/6.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

class CacheTool {
    
    var diskCacheList: [String] = []
    let config: CacheConfig
    let workQueue: DispatchQueue
    let path: String
    
    init(config: CacheConfig, diskCacheList: [String] = []) {
        self.config = config
        self.diskCacheList = diskCacheList
        self.workQueue = DispatchQueue(label: "org.AnyImageProject.AnyImageKit.DispatchQueue.CacheTool.\(config.module.title).\(config.module.subTitle)")
        
        path = config.module.path
        FileHelper.createDirectory(at: path)
    }
    
    deinit {
        if config.autoRemoveDiskCache {
            diskCacheList.forEach { deleteDiskFile(identifier: $0 ) }
        }
    }
}

extension CacheTool {
    
    /// 是否有磁盘缓存
    func hasDiskCache() -> Bool {
        return !diskCacheList.isEmpty
    }
    
    /// 删除所有缓存
    func clearAll(diskCache: Bool = false) {
        if diskCache {
            diskCacheList.forEach { deleteDiskFile(identifier: $0 ) }
        }
    }
    
    /// 删除磁盘文件
    /// - Parameter identifier: 标识符
    func deleteDiskFile(identifier: String) {
        let url = URL(fileURLWithPath: self.path + identifier)
        do {
            try FileManager.default.removeItem(at: url)
            if let idx = diskCacheList.firstIndex(of: identifier) {
                diskCacheList.remove(at: idx)
            }
        } catch {
            _print(error.localizedDescription)
        }
    }
    
    /// 创建缓存标识符
    static func createIdentifier() -> String {
        let timestamp = String(format: "%.0lf", Date().timeIntervalSince1970*100)
        let random = (arc4random() % 8999) + 1000
        return "\(timestamp)_\(random)"
    }
    
    /// 写入磁盘
    /// - Parameters:
    ///   - data: 数据
    ///   - identifier: 标识符
    func writeToFile(_ data: Data, identifier: String) {
        if !config.useDiskCache { return }
        workQueue.async { [weak self] in
            guard let self = self else { return }
            let url = URL(fileURLWithPath: self.path + identifier)
            do {
                try data.write(to: url)
            } catch {
                _print(error.localizedDescription)
            }
        }
    }
    
    /// 从磁盘读取
    /// - Parameter identifier: 标识符
    func readFromFile(_ identifier: String) -> Data? {
        if !config.useDiskCache { return nil }
        let url = URL(fileURLWithPath: path + identifier)
        if !FileManager.default.fileExists(atPath: url.path) { return nil }
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            _print(error.localizedDescription)
        }
        return nil
    }
}
