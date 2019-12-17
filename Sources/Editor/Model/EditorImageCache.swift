//
//  EditorImageCache.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/15.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

public final class EditorImageCache: Codable {
    
    let id: String
    let cropData: CropData
    let textDataList: [TextData]
    let penCacheList: [String]
    let mosaicCacheList: [String]
    
    
    /// Create cache
    init(id: String,
         cropData: CropData,
         textDataList: [TextData],
         penCacheList: [String],
         mosaicCacheList: [String]) {
        self.id = id
        self.cropData = cropData
        self.textDataList = textDataList
        self.penCacheList = penCacheList
        self.mosaicCacheList = mosaicCacheList
    }
    
    /// Load cache
    init?(id: String) {
        let url = EditorImageCache.getFileUrl(id: id)
        if !FileManager.default.fileExists(atPath: url.path) { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let obj = try? JSONDecoder().decode(EditorImageCache.self, from: data) else { return nil }
        
        self.id = id
        self.cropData = obj.cropData
        self.textDataList = obj.textDataList
        self.penCacheList = obj.penCacheList
        self.mosaicCacheList = obj.mosaicCacheList
    }
}

// MARK: - Public static function
extension EditorImageCache {
    
    /// 删除磁盘缓存
    /// - Parameter id: 缓存标识符
    static func clearDiskCache(id: String) {
        guard let obj = EditorImageCache(id: id) else { return }
        _print("Delete editor cache: \(id)")
        let _ = CacheTool(config: CacheConfig(module: .editor(.pen), useDiskCache: true, autoRemoveDiskCache: true), diskCacheList: obj.penCacheList)
        let _ = CacheTool(config: CacheConfig(module: .editor(.mosaic), useDiskCache: true, autoRemoveDiskCache: true), diskCacheList: obj.mosaicCacheList)
        
        let url = getFileUrl(id: id)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            _print(error.localizedDescription)
        }
    }
    
    /// 删除所有磁盘缓存
    static func clearDiskCache() {
        _print("Delete all editor cache")
        let path = CacheModule.editor(.history).path
        let list = ((try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []).map{ $0.replacingOccurrences(of: ".json", with: "") }
        for item in list {
            clearDiskCache(id: item)
        }
    }
}

// MARK: - Internal function
extension EditorImageCache {
    
    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: EditorImageCache.getFileUrl(id: id))
        } catch {
            _print(error.localizedDescription)
        }
    }
    
    static func getFileUrl(id: String) -> URL {
        let path = CacheModule.editor(.history).path
        let file = "\(path)\(id).json"
        FileHelper.createDirectory(at: path)
        return URL(fileURLWithPath: file)
    }
}
