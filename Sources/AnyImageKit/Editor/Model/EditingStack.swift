//
//  EditingStack.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/9.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

class EditingStack {
    
    // Load save history
    
    var currentEdit: Edit = .init()
    
    
}

extension EditingStack {
    
    struct Edit: Codable {
        
        var penData: [PenData] = []
        var mosaicData: [MosaicData] = []
        var cropData: CropData = .init()
        var textData: [TextData] = []
    }
}
