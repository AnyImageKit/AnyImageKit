//
//  AnyImageEditorOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

public enum AnyImageEditorOptionsInfoItem {
    /// Options 编辑类型
    /// - Default: []
    case options(AnyImageEditorOptions)
    
    /// Photo Config 图片编辑配置项
    case photoOptionInfoItems([AnyImageEditorPhotoOptionsInfoItem])
    
    /// Video Config 视频编辑配置项
    case videoOptionInfoItems([AnyImageEditorVideoOptionsInfoItem])
}

public struct AnyImageEditorOptionsInfo {

    public var options: AnyImageEditorOptions = []
    public var photoOptionInfoItems: [AnyImageEditorPhotoOptionsInfoItem] = [] {
        didSet {
            photoOptions = .init(photoOptionInfoItems)
        }
    }
    public var videoOptionInfoItems: [AnyImageEditorVideoOptionsInfoItem] = [] {
        didSet {
            videoOptions = .init(videoOptionInfoItems)
        }
    }
    
    var photoOptions: AnyImageEditorPhotoOptionsInfo = .init()
    var videoOptions: AnyImageEditorVideoOptionsInfo = .init()
    
    public init(_ info: [AnyImageEditorOptionsInfoItem] = []) {
        for option in info {
            switch option {
            case .options(let value): options = value
            case .photoOptionInfoItems(let value): photoOptionInfoItems = value
            case .videoOptionInfoItems(let value): videoOptionInfoItems = value
            }
        }
    }
}

/// Editor Options 编辑类型
public struct AnyImageEditorOptions: OptionSet {
    /// Photo 照片
    public static let photo = AnyImageEditorOptions(rawValue: 1 << 0)
    /// Video not finish 视频 未完成
    static let video = AnyImageEditorOptions(rawValue: 1 << 1)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
