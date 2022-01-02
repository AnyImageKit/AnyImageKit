//
//  Editor+CGPoint.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension CGPoint {
    
    static func middle(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
    }
    
    func distance(to other: CGPoint) -> CGFloat {
        let p = pow(x - other.x, 2) + pow(y - other.y, 2)
        return sqrt(p)
    }
    
    func multipliedBy(_ amount: CGFloat) -> CGPoint {
        guard amount != 1.0 else { return self }
        return CGPoint(x: x * amount, y: y * amount)
    }
    
    func reversed(_ flag: Bool = true) -> CGPoint {
        return flag ? CGPoint(x: y, y: x) : self
    }
}
