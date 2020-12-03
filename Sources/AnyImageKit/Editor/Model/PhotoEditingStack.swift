//
//  PhotoEditingStack.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/9.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

final class PhotoEditingStack {
    
    var edit: Edit = .init()
    
    private let identifier: String
    private let cache = CodableCacheTool(config: CacheConfig(module: .editor(.default), useDiskCache: true, autoRemoveDiskCache: false))
    private(set) var didLoadCache = false
    
    init(identifier: String) {
        self.identifier = identifier
        load()
    }
}

// MARK: - Save & Load
extension PhotoEditingStack {
    
    func save() {
        if identifier.isEmpty { return }
        cache.write(edit, identifier: identifier)
    }
    
    func load() {
        if identifier.isEmpty { return }
        if let model = cache.read(identifier: identifier, cls: Edit.self) {
            edit = model
            didLoadCache = true
        }
    }
}

// MARK: - Edit
extension PhotoEditingStack {
    
    struct Edit: Codable {
        
        var penData: [PenData] = []
        var mosaicData: [MosaicData] = []
        var cropData: CropData = .init()
        var textData: [TextData] = []
        
        var isEdited: Bool {
            return cropData.didCrop || !penData.isEmpty || !mosaicData.isEmpty || !textData.isEmpty
        }
    }
    
    func setMosaicData(_ dataList: [MosaicData]) {
        edit.mosaicData = dataList.filter { !$0.drawnPaths.isEmpty }
    }
}

extension PhotoEditingStack.Edit {
    
    var canvasCanUndo: Bool {
        return !penData.isEmpty
    }
    
    var mosaicCanUndo: Bool {
        return !mosaicData.flatMap { $0.drawnPaths }.isEmpty
    }
}
