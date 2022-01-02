//
//  Editor+CGRect.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension CGRect {
    
    func bigger(_ edge: UIEdgeInsets) -> CGRect {
        return CGRect(x: origin.x - edge.left, y: origin.y - edge.top, width: width + edge.left + edge.right, height: height + edge.top + edge.bottom)
    }
    
    func multipliedBy(_ amount: CGFloat) -> CGRect {
        guard amount != 1.0 else { return self }
        return CGRect(origin: origin.multipliedBy(amount), size: size.multipliedBy(amount))
    }
    
    func reversed(_ flag: Bool = true) -> CGRect {
        return flag ? CGRect(origin: origin.reversed(), size: size.reversed()) : self
    }
    
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
