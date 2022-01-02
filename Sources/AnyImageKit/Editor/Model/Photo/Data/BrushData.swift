//
//  BrushData.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/26.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

struct BrushData: Codable, Equatable {
    
    let drawnPath: DrawnPath
    
    init(drawnPath: DrawnPath) {
        self.drawnPath = drawnPath
    }
}
