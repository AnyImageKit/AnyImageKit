//
//  Core+CGFloat.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/2/9.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension CGFloat {
    
    func roundTo(places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
