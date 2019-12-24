//
//  CaptureOrientation.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/24.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import CoreImage

enum CaptureOrientation: Equatable {
    
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
}

extension CaptureOrientation {
    
    init?(uiDevice orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeLeft
        case .landscapeRight:
            self = .landscapeRight
        default:
            return nil
        }
    }
}

extension CaptureOrientation {
    
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
