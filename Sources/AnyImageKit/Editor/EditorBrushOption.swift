//
//  EditorBrushOption.swift
//  AnyImageKit
//
//  Created by Ray on 2022/1/30.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

public struct EditorBrushOption {
    
    /// Colors of brush tool options, displayed at the top of the toolbar.
    /// Option sorting is arranged in a given array.
    ///
    /// For iOS 14 and later, the last color element will use dynamic color(UIColorWell) instead of static color.
    ///
    /// For the 320pt screen, the last color element will be hidden automatically.
    ///
    /// - Default: [white, black, red, yellow, green, blue, purple]
    public var colors: [EditorBrushColorOption] = EditorBrushColorOption.allCases
    
    /// Preferred color index of brush.
    ///
    /// If the given subscript out of the `colors` bounds, it will use first color element as preferred color.
    ///
    /// - Default: 2
    public var defaultColorIndex: Int = 2
    
    /// Width of brush.
    /// - Default: 5.0
    public var lineWidth: EditorBrushWidthOption = .fixed(width: 5.0)
    
}
