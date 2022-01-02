//
//  Shadow.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/9.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

public struct Shadow: Equatable, Hashable {
    
    public let color: UIColor
    public let alpha: Float
    public let x: CGFloat
    public let y: CGFloat
    public let blur: CGFloat
    public let spread: CGFloat
    
    public init(color: UIColor, alpha: Float, x: CGFloat, y: CGFloat, blur: CGFloat, spread: CGFloat) {
        self.color = color
        self.alpha = alpha
        self.x = x
        self.y = y
        self.blur = blur
        self.spread = spread
    }
}
