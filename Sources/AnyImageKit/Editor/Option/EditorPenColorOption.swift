//
//  EditorPenColorOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

/// Pen color option
@available(*, deprecated, message: "Will be removed in version 1.0, Please use `EditorBrushColorOption` instead.")
public enum EditorPenColorOption: Equatable {
    
    /// Static color.
    case custom(color: UIColor)
    
    /// Dynamic color (UIColorWell).
    @available(iOS 14.0, *)
    case colorWell(color: UIColor)
}

@available(*, deprecated, message: "Will be removed in version 1.0, Please use `EditorBrushColorOption` instead.")
extension EditorPenColorOption: CaseIterable {
    
    public static var allCases: [EditorPenColorOption] {
        var cases: [EditorPenColorOption] = Palette.brushColors.map { .custom(color: $0) }
        if #available(iOS 14.0, *) {
            cases[cases.count-1] = .colorWell(color: Palette.brushColors.last!)
            return cases
        } else {
            return cases
        }
    }
}

@available(*, deprecated, message: "Will be removed in version 1.0, Please use `EditorBrushColorOption` instead.")
extension EditorPenColorOption {
    
    static func convertPenToBrush(_ penOptions: [EditorPenColorOption]) -> [EditorBrushColorOption] {
        return penOptions.map { options -> EditorBrushColorOption in
            switch options {
            case .custom(let color):
                return .custom(color: color)
            case .colorWell(let color):
                if #available(iOS 14.0, *) {
                    return .colorWell(color: color)
                } else {
                    fatalError()
                }
            }
        }
    }
    
    static func convertBrushToPen(_ brushOptions: [EditorBrushColorOption]) -> [EditorPenColorOption] {
        return brushOptions.map { options -> EditorPenColorOption in
            switch options {
            case .custom(let color):
                return .custom(color: color)
            case .colorWell(let color):
                if #available(iOS 14.0, *) {
                    return .colorWell(color: color)
                } else {
                    fatalError()
                }
            }
        }
    }
}
