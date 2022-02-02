//
//  EditorBrushWidthOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/1/30.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

public enum EditorBrushWidthOption: Equatable, Hashable {
    
    case fixed(width: CGFloat)
    
    case dynamic(defaultWidth: CGFloat, minimumWidth: CGFloat, maximumWidth: CGFloat)
}

// MARK: - Private
extension EditorBrushWidthOption {
    
    var width: CGFloat {
        switch self {
        case .fixed(let width):
            return width
        case .dynamic(let defaultWidth, _, _):
            return defaultWidth
        }
    }
    
    var isDynamic: Bool {
        switch self {
        case .fixed:
            return false
        case .dynamic:
            return true
        }
    }
    
    func percent(of width: CGFloat) -> Float {
        switch self {
        case .fixed:
            return 1.0
        case .dynamic(_, let minimumWidth, let maximumWidth):
            return Float((width - minimumWidth) / (maximumWidth - minimumWidth))
        }
    }
    
    func width(of precent: Float) -> CGFloat {
        switch self {
        case .fixed(let width):
            return width
        case .dynamic(_, let minimumWidth, let maximumWidth):
            return (maximumWidth - minimumWidth) * CGFloat(precent) + minimumWidth
        }
    }
}
