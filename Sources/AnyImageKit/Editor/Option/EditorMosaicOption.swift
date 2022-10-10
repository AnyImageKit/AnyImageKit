//
//  EditorMosaicOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

public struct EditorMosaicOption: Equatable {
    
    /// Mosaic style of mosaic tool options, displayed at the top of the toolbar.
    /// Option sorting is arranged in a given array.
    ///
    /// You can customize your own mosaic style if you want. See `EditorMosaicOption` for more details.
    ///
    /// - Default: [default, colorful]
    public var style: [EditorMosaicStyleOption] = EditorMosaicStyleOption.allCases
    
    /// Preferred mosaic style index of mosaic.
    ///
    /// If the given subscript out of the `mosaicOptions` bounds, it will use first mosaic element as preferred mosaic style.
    ///
    /// - Default: 2
    public var defaultMosaicIndex: Int = 0
    
    /// Width of mosaic.
    /// - Default: 15.0
    public var lineWidth: EditorBrushWidthOption = .fixed(width: 15.0)
    
    /// Mosaic blur level, only for default mosaic style.
    /// - Default: 30
    public var level: Int = 30
}
