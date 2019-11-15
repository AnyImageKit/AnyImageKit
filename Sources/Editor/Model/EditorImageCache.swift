//
//  EditorImageCache.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/15.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

final class EditorImageCache: Codable {
    
    let id: String
    let penCacheList: [String]
    let mosaicCacheList: [String]
    let cropData: CropData
    
    /// Create cache
    init(id: String,
         cropData: CropData,
         penCacheList: [String],
         mosaicCacheList: [String]) {
        self.id = id
        self.cropData = cropData
        self.penCacheList = penCacheList
        self.mosaicCacheList = mosaicCacheList
    }
    
    /// Load cache
    init?(id: String) {
        guard let data = try? Data(contentsOf: EditorImageCache.getFileUrl(id: id)) else { return nil }
        guard let obj = try? JSONDecoder().decode(EditorImageCache.self, from: data) else { return nil }
        
        self.id = id
        self.cropData = obj.cropData
        self.penCacheList = obj.penCacheList
        self.mosaicCacheList = obj.mosaicCacheList
    }
}

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
        let lib = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
        let path = "\(lib)/AnyImageKitCache/Editor/ImageCache/\(id)"
        return URL(fileURLWithPath: path)
    }
}
