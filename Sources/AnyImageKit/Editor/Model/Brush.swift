//
//  Brush.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

/// 画笔，描述 path 的样式
struct Brush: Equatable {
    
    var color: UIColor = .red
    var lineWidth: CGFloat = 5.0
    
    static func == (lhs: Brush, rhs: Brush) -> Bool {
        guard lhs.color == rhs.color else { return false }
        guard lhs.lineWidth == rhs.lineWidth else { return false }
        return true
    }
}
