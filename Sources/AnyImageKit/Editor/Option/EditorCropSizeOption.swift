//
//  EditorCropSizeOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

/// Crop option
public enum EditorCropSizeOption: Equatable {
    
    /// Free crop, there is no crop size limit.
    case free
    
    /// Limit crop size, limit the cropping width and height ratio. Eg. w:3 h:4
    case custom(w: UInt, h: UInt)
}

extension EditorCropSizeOption: CaseIterable {
    
    public static var allCases: [EditorCropSizeOption] {
        return [.free, .custom(w: 1, h: 1), .custom(w: 3, h: 4), .custom(w: 4, h: 3), .custom(w: 9, h: 16), .custom(w: 16, h: 9)]
    }
}

extension EditorCropSizeOption {
    
    var ratioOfWidth: CGFloat {
        switch self {
        case .free:
            return 1
        case .custom(let w, let h):
            return CGFloat(w)/CGFloat(h)
        }
    }
    
    var ratioOfHeight: CGFloat {
        switch self {
        case .free:
            return 1
        case .custom(let w, let h):
            return CGFloat(h)/CGFloat(w)
        }
    }
}
