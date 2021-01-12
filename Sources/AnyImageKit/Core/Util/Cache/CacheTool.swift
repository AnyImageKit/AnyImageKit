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
        FileHelper.createDirectory(at: path)
    }
}

// MARK: - Function
extension CacheTool {
    
    /// 删除磁盘文件
    /// - Parameter identifier: 标识符
    func deleteDiskFile(identifier: String) {
        let url = URL(fileURLWithPath: self.path + identifier)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            _print(error.localizedDescription)
        }
    }
    
    /// 写入磁盘
    /// - Parameters:
    ///   - data: 数据
    ///   - identifier: 标识符
    func writeToFile(_ data: Data, identifier: String) {
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

// MARK: - Static function
extension CacheTool {
    
    static func deleteDiskFiles(pathList: [String]) {
        let manager = FileManager.default
        for path in pathList {
            let url = URL(fileURLWithPath: path)
            do {
                try manager.removeItem(at: url)
            } catch {
                _print(error.localizedDescription)
            }
        }
    }
}
