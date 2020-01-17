//
//  EditorVideoOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

public typealias EditorVideoOptionsInfo = [EditorVideoOptionsInfoItem]

public enum EditorVideoOptionsInfoItem: OptionsInfoItem {
    
    /// 主题色
    /// 默认：green
    case tintColor(UIColor)
    
    /// 编辑功能，会按顺序排布
    /// 默认：[.crop]
    case toolOptions([EditorVideoToolOption])
    
    /// 启用调试日志
    /// 默认：false
    case enableDebugLog
}

public struct EditorVideoParsedOptionsInfo: Equatable {
    
    public var tintColor: UIColor = Palette.main
    public var toolOptions: [EditorVideoToolOption] = [.crop]
    public var enableDebugLog: Bool = false
    
    public init(_ info: [EditorVideoOptionsInfoItem] = []) {
        for option in info {
            switch option {
            case .tintColor(let value): tintColor = value
            case .toolOptions(let value): toolOptions = value
            case .enableDebugLog: enableDebugLog = true
            }
        }
    }
    
    public var infoItems: EditorVideoOptionsInfo {
        var items: EditorVideoOptionsInfo
        items = [.tintColor(tintColor),
                   .toolOptions(toolOptions)]
        if enableDebugLog {
            items.append(.enableDebugLog)
        }
        return items
    }
}

/// 视频编辑功能
public enum EditorVideoToolOption: Equatable {
    /// 裁剪
    case crop
}

// MARK: - Extension
extension EditorVideoToolOption: CustomStringConvertible {
    var imageName: String {
        switch self {
        case .crop:
            return "VideoToolVideo"
        }
    }
    
    public var description: String {
        switch self {
        case .crop:
            return "Crop"
        }
    }
}
