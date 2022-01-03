//
//  Cacheable.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/6.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol Cacheable {
    
    var module: CacheModule { get }
    var path: String { get }
    var workQueue: DispatchQueue { get }
}

extension Cacheable {
    
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
        workQueue.async {
            let url = URL(fileURLWithPath: path + key)
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
