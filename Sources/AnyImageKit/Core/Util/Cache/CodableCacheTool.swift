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
    func write<T: Codable>(_ model: T, identifier: String = createIdentifier()) {
        diskCacheList.append(identifier)
        do {
            let data = try JSONEncoder().encode(model)
            super.writeToFile(data, identifier: identifier)
        } catch {
            _print(error.localizedDescription)
        }
    }
    
    /// 读取缓存
    /// - Parameters:
    ///   - identifier: 标识符
    ///   - cls: 类型
    ///   - deleteDiskStorage: 读取缓存后删除磁盘缓存
    func read<T: Codable>(identifier: String, cls: T.Type, deleteDiskStorage: Bool = false) -> T? {
        guard let data = super.readFromFile(identifier) else { return nil }
        do {
            let model = try JSONDecoder().decode(cls, from: data)
            if deleteDiskStorage {
                deleteDiskFile(identifier: identifier)
            }
            return model
        } catch {
            _print(error.localizedDescription)
        }
        return nil
    }
}
