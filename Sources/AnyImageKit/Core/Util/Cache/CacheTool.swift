//
//  CacheTool.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/6.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

class CacheTool {
    
    let module: CacheModule
    let path: String
    let workQueue: DispatchQueue
    
    init(module: CacheModule, path: String = "") {
        self.module = module
        self.path = path.isEmpty ? module.path : path
        self.workQueue = DispatchQueue(label: "org.AnyImageProject.AnyImageKit.DispatchQueue.CacheTool.\(module.title).\(module.subTitle)")
        FileHelper.createDirectory(at: self.path)
    }
}

extension CacheTool {
    
    /// 删除磁盘数据
    /// - Parameter key: 标识符
    func removeData(forKey key: String) {
        let url = URL(fileURLWithPath: self.path + key)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            _print(error.localizedDescription)
        }
    }
    
    /// 数据写入磁盘
    /// - Parameters:
    ///   - data: 数据
    ///   - key: 标识符
    func storeDataToDisk(_ data: Data, forKey key: String) {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            let url = URL(fileURLWithPath: self.path + key)
            do {
                try data.write(to: url)
            } catch {
                _print(error.localizedDescription)
            }
        }
    }
    
    /// 从磁盘读取数据
    /// - Parameter key: 标识符
    func retrieveDataInDisk(forKey key: String) -> Data? {
        let url = URL(fileURLWithPath: path + key)
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
