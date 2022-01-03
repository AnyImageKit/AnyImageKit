//
//  Editor+CABasicAnimation.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/4.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension CABasicAnimation {
    
    static func create(keyPath: String = "path", duration: CFTimeInterval, fromValue: Any?, toValue: Any?) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
}
