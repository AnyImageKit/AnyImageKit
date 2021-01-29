//
//  PenData.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/26.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Foundation

struct PenData: Codable, Equatable {
    
    let drawnPath: DrawnPath
    
    init(drawnPath: DrawnPath) {
        self.drawnPath = drawnPath
    }
}
