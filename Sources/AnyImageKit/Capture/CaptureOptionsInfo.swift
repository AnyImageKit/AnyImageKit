//
//  CaptureOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import AVFoundation

public struct CaptureOptionsInfo {
    
    /// 主题色
    /// 默认：绿色 0x57BE6A
    public var tintColor: UIColor = UIColor.color(hex: 0x57BE6A)
    
    /// 媒体类型
    /// 默认：Photo+Video
    public var mediaOptions: CaptureMediaOption = [.photo, .video]
    
    /// 照片拍摄比例
    /// iPadOS 环境下无效
    /// 默认：4:3
    public var photoAspectRatio: CaptureAspectRatio = .ratio4x3
    
    /// 使用的摄像头
    /// iPadOS 环境下仅用于先打开前置/后置摄像头，用户仍然可以切换摄像头
    /// 默认：后置+前置
    public var preferredPositions: [CapturePosition] = [.back, .front]
    
    /// 默认闪光灯模式
    /// 默认：关闭
    public var flashMode: CaptureFlashMode = .off
    
    /// 视频拍摄最大时间
    /// 默认 20 秒
    public var videoMaximumDuration: TimeInterval = 20
    
    /// 相机预设
    /// iPadOS 环境下无效
    /// 默认支持从 1920*1080@60 开始查找支持的最佳分辨率
    public var preferredPresets: [CapturePreset] = CapturePreset.createPresets(enableHighResolution: false, enableHighFrameRate: true)
    
    /// 启用调试日志
    /// 默认：false
    public var enableDebugLog: Bool = false
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    /// Editor photo option info items 图片编辑配置项
    /// iPadOS 环境下无效
    public var editorPhotoOptions: EditorPhotoOptionsInfo = .init()
    
    /// Editor video option info items 视频编辑配置项
    /// iPadOS 环境下无效
    public var editorVideoOptions: EditorVideoOptionsInfo = .init()
    #endif
    
    public init() { }
}

public struct CaptureMediaOption: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let photo = CaptureMediaOption(rawValue: 1 << 0)
    
    public static let video = CaptureMediaOption(rawValue: 1 << 1)
}

extension CaptureMediaOption {
    
    var localizedTips: String {
        if contains(.photo) && contains(.video) {
            return BundleHelper.localizedString(key: "HOLD_FOR_VIDEO_TAP_FOR_PHOTO", module: .capture)
        }
        if contains(.photo) {
            return BundleHelper.localizedString(key: "TAP_FOR_PHOTO", module: .capture)
        }
        if contains(.video) {
            return BundleHelper.localizedString(key: "HOLD_FOR_VIDEO", module: .capture)
        }
        return ""
    }
}

public enum CaptureAspectRatio: Equatable {
    
    case ratio1x1
    case ratio4x3
    case ratio16x9
    
    var value: Double {
        switch self {
        case .ratio1x1:
            return 1.0/1.0
        case .ratio4x3:
            return 3.0/4.0
        case .ratio16x9:
            return 9.0/16.0
        }
    }
    
    var cropValue: CGFloat {
        switch self {
        case .ratio1x1:
            return 9.0/16.0
        case .ratio4x3:
            return 3.0/4.0
        case .ratio16x9:
            return 1.0/1.0
        }
    }
}
