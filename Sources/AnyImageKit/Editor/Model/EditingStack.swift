//
//  PhotoEditingStack.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/9.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

final class PhotoEditingStack {
    
    // Load save history
    
    var currentEdit: Edit = .init()
    
    var isEdited: Bool {
        return currentEdit.cropData.didCrop || !currentEdit.penData.isEmpty || !currentEdit.mosaicData.isEmpty || !currentEdit.textData.isEmpty
    }
    
}

extension PhotoEditingStack {
    
    struct Edit: Codable {
        
        var penData: [PenData] = []
        var mosaicData: [MosaicData] = []
        var cropData: CropData = .init()
        var textData: [TextData] = []
    }
}
