//
//  EditorVideoOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

public struct EditorVideoOptionsInfo {
    
    /// Theme
    public var theme: EditorTheme = .init()
    
    /// Tool options for the Video Editor, displayed at the bottom of the editor.
    /// Option sorting is arranged in a given array.
    ///
    /// - Default: [clip]
    public var toolOptions: [EditorVideoToolOption] = [.clip]
    
    /// Enable debug log
    /// - Default: false
    public var enableDebugLog: Bool = false

    public init() { }
}

// MARK: - Deprecated
extension EditorVideoOptionsInfo {
    
    @available(*, deprecated, message: "Will be removed in version 1.0, Please set `theme[color: .primary]` instead.")
    public var tintColor: UIColor {
        get { theme[color: .primary] }
        set { theme[color: .primary] = newValue }
    }
}
