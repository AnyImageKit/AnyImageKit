//
//  EditorPhotoOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

public struct EditorPhotoOptionsInfo {
    
    /// Tint color.
    /// - Default: Green
    public var tintColor: UIColor = Palette.main
    
    /// Tool options for the Photo Editor, displayed at the bottom of the editor.
    /// Option sorting is arranged in a given array.
    ///
    /// - Default: [brush, text, crop, mosaic]
    public var toolOptions: [EditorPhotoToolOption] = EditorPhotoToolOption.allCases
    
    /// Colors of brush tool options, displayed at the top of the toolbar.
    /// Option sorting is arranged in a given array.
    ///
    /// For iOS 14 and later, the last color element will use dynamic color(UIColorWell) instead of static color.
    ///
    /// For the 320pt screen, the last color element will be hidden automatically.
    ///
    /// - Default: [white, black, red, yellow, green, blue, purple]
    public var brushColors: [EditorBrushColorOption] = EditorBrushColorOption.allCases
    
    /// Preferred color index of brush.
    ///
    /// If the given subscript out of the `brushColors` bounds, it will use first color element as preferred color.
    ///
    /// - Default: 2
    public var defaultBrushIndex: Int = 2
    
    /// Width of brush.
    /// - Default: 5.0
    public var brushWidth: CGFloat = 5.0
    
    /// Mosaic style of mosaic tool options, displayed at the top of the toolbar.
    /// Option sorting is arranged in a given array.
    ///
    /// You can customize your own mosaic style if you want. See `EditorMosaicOption` for more details.
    ///
    /// - Default: [default, colorful]
    public var mosaicOptions: [EditorMosaicOption] = EditorMosaicOption.allCases
    
    /// Preferred mosaic style index of mosaic.
    ///
    /// If the given subscript out of the `mosaicOptions` bounds, it will use first mosaic element as preferred mosaic style.
    ///
    /// - Default: 2
    public var defaultMosaicIndex: Int = 0
    
    /// Width of mosaic.
    /// - Default: 15.0
    public var mosaicWidth: CGFloat = 15.0
    
    /// Mosaic blur level, only for default mosaic style.
    /// - Default: 30
    public var mosaicLevel: Int = 30
    
    /// Colors of input text.
    /// Option sorting is arranged in a given array.
    ///
    /// There are two display styles for each color element.
    /// One is no background color, the text color is main color.
    /// The other is that the background color is main color, and the text color is sub color(usually is white).
    ///
    /// - Default: [white, black, red, yellow, green, blue, purple]
    public var textColors: [EditorTextColor] = Palette.textColors
    
    /// Crop size of crop tool options.
    /// Option sorting is arranged in a given array.
    ///
    /// You can customize crop size if you want.
    ///
    /// - Default: [free, 1:1, 3:4, 4:3, 9:16, 16:9]
    public var cropOptions: [EditorCropOption] = EditorCropOption.allCases
    
    /// Setting the cache identifier will cache the edit records.
    /// The next time you open the editor, it will load the edit records and restore it.
    ///
    /// If you try to edit a photo from the ImagePicker, you will see that the last edited content can be undo, which means that the editor has restored the last edit records.
    ///
    /// Use `ImageEditorCache` to remove cache.
    ///
    /// - Note: The '/' character is not allowed in the cache identifier.
    ///
    /// - Default: "" that means DO NOT cache the edit records.
    public var cacheIdentifier: String = ""
    
    /// Enable debug log
    /// - Default: false
    public var enableDebugLog: Bool = false
    
    public init() { }
}

// MARK: - Deprecated
extension EditorPhotoOptionsInfo {
    
    @available(*, deprecated, message: "Will be removed in version 1.0, Please use `EditorBrushColorOption` instead.")
    public var penColors: [EditorPenColorOption] {
        get {
            return EditorPenColorOption.convertBrushToPen(brushColors)
        } set {
            brushColors = EditorPenColorOption.convertPenToBrush(newValue)
        }
    }
    
    @available(*, deprecated, message: "Will be removed in version 1.0, Please use `defaultBrushIndex` instead.")
    public var defaultPenIndex: Int {
        get {
            return defaultBrushIndex
        } set {
            defaultBrushIndex = newValue
        }
    }
    
    @available(*, deprecated, message: "Will be removed in version 1.0, Please use `brushWidth` instead.")
    public var penWidth: CGFloat {
        get {
            return brushWidth
        } set {
            brushWidth = newValue
        }
    }
}
