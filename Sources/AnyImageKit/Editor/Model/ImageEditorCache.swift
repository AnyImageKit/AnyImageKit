//
//  ImageEditorCache.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/15.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import Foundation

public final class ImageEditorCache {

}

// MARK: - Public static function
extension ImageEditorCache {
    
    /// 删除磁盘缓存
    /// - Parameter id: 缓存标识符
    public static func clearDiskCache(id: String) {
        let cache = CodableCacheTool(config: CacheConfig(module: .editor(.default)))
        guard let model = cache.read(identifier: id, cls: PhotoEditingStack.Edit.self) else { return }
        
        var pathList = model.penData.map { $0.drawnPath.uuid }
        pathList.append(contentsOf: model.mosaicData.flatMap { $0.drawnPaths.map { $0.uuid } })
        let _ = CacheTool(config: CacheConfig(module: .editor(.bezierPath), useDiskCache: true, autoRemoveDiskCache: true), diskCacheList: pathList)
        
        do {
            try FileManager.default.removeItem(atPath: "\(cache.path)\(id)")
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
