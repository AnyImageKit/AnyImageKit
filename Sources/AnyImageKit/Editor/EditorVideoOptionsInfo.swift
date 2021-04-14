//
//  EditorVideoOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

public struct EditorVideoOptionsInfo {
    
    /// Tint color.
    /// - Default: Green
    public var tintColor: UIColor = Palette.main
    
    /// Tool options for the Video Editor, displayed at the bottom of the editor.
    /// Option sorting is arranged in a given array.
    ///
    /// - Default: [.clip]
    public var toolOptions: [EditorVideoToolOption] = [.clip]
    
    /// Enable debug log
    /// - Default: false
    public var enableDebugLog: Bool = false

    public init() { }
}
