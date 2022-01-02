//
//  EditorBrushColorOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/19.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

/// Brush color option
public enum EditorBrushColorOption: Equatable, Hashable {
    
    /// Static color.
    case custom(color: UIColor)
    
    /// Dynamic color (UIColorWell).
    case colorWell(color: UIColor)
}

extension EditorBrushColorOption: CaseIterable {
    
    public static var allCases: [EditorBrushColorOption] {
        var cases: [EditorBrushColorOption] = Palette.brushColors.map { .custom(color: $0) }
        if #available(iOS 14.0, *) {
            cases[cases.count-1] = .colorWell(color: Palette.brushColors.last!)
            return cases
        } else {
            return cases
        }
    }
}

extension EditorBrushColorOption {
    
    var color: UIColor {
        switch self {
        case .custom(let color):
            return color
        case .colorWell(let color):
            return color
        }
    }
}
