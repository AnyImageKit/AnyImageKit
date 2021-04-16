//
//  EditorPenColorOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

/// Pen color option
public enum EditorPenColorOption: Equatable {
    
    /// Static color.
    case custom(color: UIColor)
    
    /// Dynamic color (UIColorWell).
    @available(iOS 14.0, *)
    case colorWell(color: UIColor)
}

extension EditorPenColorOption: CaseIterable {
    
    public static var allCases: [EditorPenColorOption] {
        var cases: [EditorPenColorOption] = Palette.penColors.map { .custom(color: $0) }
        if #available(iOS 14.0, *) {
            cases[cases.count-1] = .colorWell(color: Palette.penColors.last!)
            return cases
        } else {
            return cases
        }
    }
}

extension EditorPenColorOption {
    
    var color: UIColor {
        switch self {
        case .custom(let color):
            return color
        case .colorWell(let color):
            return color
        }
    }
}
