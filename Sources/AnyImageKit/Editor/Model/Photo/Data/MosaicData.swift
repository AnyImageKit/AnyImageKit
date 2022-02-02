//
//  MosaicData.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/26.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

struct MosaicData: Codable {
    
    let idx: Int
    let uuid: String
    let drawnPaths: [DrawnPath]
    
    init(idx: Int,
         drawnPaths: [DrawnPath],
         uuid: String) {
        self.idx = idx
        self.drawnPaths = drawnPaths
        self.uuid = uuid
    }
}

// MARK: - Equatable
extension MosaicData: Equatable {
    
    static func == (lhs: MosaicData, rhs: MosaicData) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
