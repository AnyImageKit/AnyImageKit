//
//  EditorCropOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/7/6.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public struct EditorCropOption: Equatable {
    
    /// Crop size of crop tool options.
    /// Option sorting is arranged in a given array.
    ///
    /// You can customize crop size if you want.
    ///
    /// - Default: [free, 1:1, 3:4, 4:3, 9:16, 16:9]
    public var sizes: [EditorCropSizeOption] = EditorCropSizeOption.allCases
    
    /// Rotation direction feature of crop toolbar.
    ///
    /// - Note: Custom crop option must appear in pairs if you turn on the rotation feature.
    ///
    /// For example, if you set cropOptions = [3:4, 9:16], editor will update cropOptions to [3:4, 4:3, 9:16, 16:9] automatically.
    ///
    /// - Default: turnLeft
    public var rotationDirection: EditorRotationDirection = .turnLeft
}
