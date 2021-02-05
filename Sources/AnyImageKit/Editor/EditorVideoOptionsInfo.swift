//
//  EditorVideoOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

public struct EditorVideoOptionsInfo {
    
    /// 主题色
    /// 默认：green
    public var tintColor: UIColor = Palette.main
    
    /// 编辑功能，会按顺序排布
    /// 默认：[.clip]
    public var toolOptions: [EditorVideoToolOption] = [.clip]
    
    /// 启用调试日志
    /// 默认：false
    public var enableDebugLog: Bool = false

    public init() { }
}

/// 视频编辑功能
public enum EditorVideoToolOption: Equatable {
    /// 剪辑
    case clip
}

// MARK: - Extension
extension EditorVideoToolOption {
    
    var imageName: String {
        switch self {
        case .clip:
            return "VideoToolVideo"
        }
    }
}

extension EditorVideoToolOption: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .clip:
            return "CROP"
        }
    }
}
