//
//  GraphicsDrawing.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/9.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol GraphicsDrawing {
    
    func draw(in context: CGContext, size: CGSize)
}
