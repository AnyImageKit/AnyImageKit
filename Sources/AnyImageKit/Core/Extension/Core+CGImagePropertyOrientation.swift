//
//  Core+CGImagePropertyOrientation.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/26.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import ImageIO
import UIKit

extension CGImagePropertyOrientation {
    
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
