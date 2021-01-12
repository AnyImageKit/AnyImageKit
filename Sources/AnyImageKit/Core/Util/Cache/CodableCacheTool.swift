//
//  CodableCacheTool.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/1.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class CodableCacheTool: CacheTool {
    
    // None memory cache
}

extension CodableCacheTool {
    
    /// 写入缓存
    /// - Parameters:
    ///   - model: 模型
    ///   - identifier: 标识符
    func store<T: Codable>(_ model: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(model)
            super.storeDataToDisk(data, forKey: key)
        } catch {
            _print(error.localizedDescription)
        }
    }
    
    /// 读取缓存
    /// - Parameters:
    ///   - identifier: 标识符
    ///   - cls: 类型
    ///   - deleteDiskStorage: 读取缓存后删除磁盘缓存
    func retrieveModel<T: Codable>(forKey key: String, cls: T.Type, deleteDiskStorage: Bool = false) -> T? {
        guard let data = super.retrieveDataInDisk(forKey: key) else { return nil }
        do {
            let model = try JSONDecoder().decode(cls, from: data)
            if deleteDiskStorage {
                removeData(forKey: key)
            }
            return model
        } catch {
            _print(error.localizedDescription)
        }
        return nil
    }
}
