//
//  ImageEditorCache.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/15.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public final class ImageEditorCache {

}

// MARK: - Public static function
extension ImageEditorCache {
    
    /// Delete disk cache file by identifier.
    /// - Parameter identifier: Cache identifier
    public static func removeCache(identifier: String) {
        let cache = CodableCacheTool(module: .editor(.default))
        guard let model: PhotoEditingStack.Edit = cache.retrieveModel(forKey: identifier) else { return }
        removeImageCache(model: model, mainFilePath: "\(cache.path)\(identifier)")
    }
    
    /// Delete all disk cache
    public static func clearDiskCache() {
        _print("Delete all editor cache")
        clearImageEditorCache()
    }
    
    /// Delete all Photo Editor disk cache
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

// MARK: - Private static function
extension ImageEditorCache {
    
    private static func removeImageCache(model: PhotoEditingStack.Edit, mainFilePath: String) {
        var pathList = model.brushData.map { $0.drawnPath.uuid }
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
            try FileManager.default.removeItem(atPath: mainFilePath)
        } catch {
            _print(error.localizedDescription)
        }
    }
}

// MARK: - Deprecated
extension ImageEditorCache {
    
    /// Delete disk cache file by identifier.
    /// - Parameter id: Cache identifier
    @available(*, deprecated, renamed: "removeCache(identifier:)", message: "Will be removed in version 1.0, Please use `removeCache(:)` instead.")
    public static func clearDiskCache(id: String) {
        removeCache(identifier: id)
    }
}
