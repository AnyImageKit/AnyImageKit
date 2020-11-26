//
//  PenData.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/26.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import Foundation

struct PenData: Codable {
    
    let drawnPath: DrawnPath
    
    init(drawnPath: DrawnPath) {
        self.drawnPath = drawnPath
    }
}
