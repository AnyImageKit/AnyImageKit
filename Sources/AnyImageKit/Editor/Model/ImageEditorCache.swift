//
//  ImageEditorCache.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/15.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public final class ImageEditorCache {

}

// MARK: - Public static function
extension ImageEditorCache {
    
    /// 删除指定磁盘缓存
    /// - Parameter identifier: 缓存标识符
    @available(*, deprecated, message: "Will be removed in version 1.0, Please use `removeCache(:)` instead.")
    public static func clearDiskCache(id: String) {
        removeCache(identifier: id)
    }
    
    /// 删除指定磁盘缓存
    /// - Parameter identifier: 缓存标识符
    public static func removeCache(identifier: String) {
        let cache = CodableCacheTool(module: .editor(.default))
        guard let model: PhotoEditingStack.Edit = cache.retrieveModel(forKey: identifier) else { return }
        
        var pathList = model.penData.map { $0.drawnPath.uuid }
        pathList.append(contentsOf: model.mosaicData.flatMap { $0.drawnPaths.map { $0.uuid } })
        pathList = pathList.map { CacheModule.editor(.bezierPath).path + $0 }
        let manager = FileManager.default
        for path in pathList {
            let url = URL(fileURLWithPath: path)
            do {
                try manager.removeItem(at: url)
            } catch {
                _print(error.localizedDescription)
            }
        }
        
        do {
            try FileManager.default.removeItem(atPath: "\(cache.path)\(identifier)")
        } catch {
            _print(error.localizedDescription)
        }
    }
    
    /// 删除所有磁盘缓存
    public static func clearDiskCache() {
        _print("Delete all editor cache")
        clearImageEditorCache()
    }
    
    /// 删除图片编辑的磁盘缓存
    public static func clearImageEditorCache() {
        for module in CacheModuleEditor.imageModule {
            let path = CacheModule.editor(module).path
            var directoryExists: ObjCBool = false
            FileManager.default.fileExists(atPath: path, isDirectory: &directoryExists)
            if directoryExists.boolValue {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    _print(error.localizedDescription)
                }
            }
        }
    }
}
