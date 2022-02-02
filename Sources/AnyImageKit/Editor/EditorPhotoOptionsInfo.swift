//
//  EditorPhotoOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

public struct EditorPhotoOptionsInfo {
    
    /// Theme
    public var theme: EditorTheme = .init()
    
    /// Tool options for the Photo Editor, displayed at the bottom of the editor.
    /// Option sorting is arranged in a given array.
    ///
    /// - Default: [brush, text, crop, mosaic]
    public var toolOptions: [EditorPhotoToolOption] = EditorPhotoToolOption.allCases
    
    public var brush: EditorBrushOption = .init()
    
    public var mosaic: EditorMosaicOption = .init()
    
    /// Colors of input text.
    /// Option sorting is arranged in a given array.
    ///
    /// There are two display styles for each color element.
    /// One is no background color, the text color is main color.
    /// The other is that the background color is main color, and the text color is sub color(usually is white).
    ///
    /// - Default: [white, black, red, yellow, green, blue, purple]
    public var textColors: [EditorTextColor] = Palette.textColors
    
    /// Font of intput text.
    ///
    /// - Default: .systemFont(ofSize: 32, weight: .bold)
    public var textFont: UIFont = .systemFont(ofSize: 32, weight: .bold)
    
    /// Style of input text at the first time.
    ///
    /// false: No background color, and the text color is main color.
    ///
    /// true: The background color is main color, and the text color is sub color.
    ///
    /// - Default: true
    public var isTextSelected: Bool = true
    
    /// Calculate text last line mask width when input text.
    ///
    /// false: The last line mask width equal to text view width.
    ///
    /// true: The last line mask width equal to text length.
    ///
    /// - Default: true
    public var calculateTextLastLineMask: Bool = true
    
    /// Crop size of crop tool options.
    /// Option sorting is arranged in a given array.
    ///
    /// You can customize crop size if you want.
    ///
    /// - Default: [free, 1:1, 3:4, 4:3, 9:16, 16:9]
    public var cropOptions: [EditorCropOption] = EditorCropOption.allCases
    
    /// Rotation direction feature of crop toolbar.
    ///
    /// - Note: Custom crop option must appear in pairs if you turn on the rotation feature.
    ///
    /// For example, if you set cropOptions = [3:4, 9:16], editor will update cropOptions to [3:4, 4:3, 9:16, 16:9] automatically.
    ///
    /// - Default: turnLeft
    public var rotationDirection: EditorRotationDirection = .turnLeft
    
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

// MARK: - Private
struct EditorPhotoOptionsInfoKey: InjectionKey {
    
    static var currentValue = EditorPhotoOptionsInfo()
}

extension InjectedValues {
    
    var photoOptions: EditorPhotoOptionsInfo {
        get { Self[EditorPhotoOptionsInfoKey.self] }
        set { Self[EditorPhotoOptionsInfoKey.self] = newValue }
    }
}
