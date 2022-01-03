//
//  DeviceOrientation.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/24.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import CoreImage

enum DeviceOrientation: Equatable {
    
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
}

extension DeviceOrientation {
    
    var exifOrientation: Int32 {
        return Int32(cgImagePropertyOrientation.rawValue)
    }
    
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch self {
        case .portrait:
            return .up
        case .portraitUpsideDown:
            return .down
        case .landscapeLeft:
            return .left
        case .landscapeRight:
            return .right
        }
    }
}

extension DeviceOrientation {
    
    var transform: CGAffineTransform {
        switch self {
        case .portrait:
            return CGAffineTransform(rotationAngle: 0)
        case .portraitUpsideDown:
            return CGAffineTransform(rotationAngle: .pi)
        case .landscapeLeft:
            return CGAffineTransform(rotationAngle: .pi/2*3)
        case .landscapeRight:
            return CGAffineTransform(rotationAngle: .pi/2)
        }
    }
    
    var transformMirrored: CGAffineTransform {
        switch self {
        case .portrait:
            return CGAffineTransform(rotationAngle: 0)
        case .portraitUpsideDown:
            return CGAffineTransform(rotationAngle: .pi)
        case .landscapeLeft:
            return CGAffineTransform(rotationAngle: .pi/2)
        case .landscapeRight:
            return CGAffineTransform(rotationAngle: .pi/2*3)
        }
    }
}
