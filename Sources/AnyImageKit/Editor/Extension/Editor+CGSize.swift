//
//  Editor+CGSize.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/15.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension CGSize {
    
    func multipliedBy(_ amount: CGFloat) -> CGSize {
        guard amount != 1.0 else { return self }
        return CGSize(width: width * amount, height: height * amount)
    }
    
    /// 宽高交换
    /// flag: true=交换; false=不交换
    func reversed(_ flag: Bool = true) -> CGSize {
        return flag ? CGSize(width: height, height: width) : self
    }
    
    func roundTo(places: Int) -> CGSize {
        return CGSize(width: width.roundTo(places: 1), height: height.roundTo(places: 1))
    }
}
