//
//  CaptureOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import AVFoundation

public typealias CaptureOptionsInfo = [CaptureOptionsInfoItem]

public enum CaptureOptionsInfoItem: OptionsInfoItem {
    
    /// 主题色
    /// 默认：绿色 0x57BE6A
    case tintColor(UIColor)
    
    /// 媒体类型
    /// 默认：Photo+Video
    case mediaOptions(CaptureMediaOption)
    
    /// 照片拍摄比例
    /// 默认：4:3
    case photoAspectRatio(CaptureAspectRatio)
    
    /// 使用的摄像头
    /// 默认：后置+前置
    case preferredPositions([AVCaptureDevice.Position])
    
    /// 默认闪光灯模式
    /// 默认：关闭
    case flashMode(AVCaptureDevice.FlashMode)
    
    /// 视频拍摄最大时间
    /// 默认 20 秒
    case videoMaximumDuration(TimeInterval)
    
    /// 相机预设
    /// 默认支持从 1920*1080@60 开始查找支持的最佳分辨率
    case preferredPreset([CapturePreset])
    
    /// 启用调试日志
    /// 默认：false
    case enableDebugLog
}

public struct CaptureParsedOptionsInfo: Equatable {
    
    public var tintColor: UIColor = UIColor.color(hex: 0x57BE6A)
    public var mediaOptions: CaptureMediaOption = [.photo, .video]
    public var photoAspectRatio: CaptureAspectRatio = .ratio4x3
    public var preferredPositions: [AVCaptureDevice.Position] = [.back, .front]
    public var flashMode: AVCaptureDevice.FlashMode = .off
    public var videoMaximumDuration: TimeInterval = 20
    public var preferredPreset: [CapturePreset] = [.fhd1920x1080_60, .fhd1920x1080_30, .hd1280x720_60, .hd1280x720_30]
    public var enableDebugLog: Bool = false
    
    public init(_ info: [CaptureOptionsInfoItem] = []) {
        for option in info {
            switch option {
            case .tintColor(let value): tintColor = value
            case .mediaOptions(let value): mediaOptions = value
            case .photoAspectRatio(let value): photoAspectRatio = value
            case .preferredPositions(let value): preferredPositions = value
            case .flashMode(let value): flashMode = value
            case .videoMaximumDuration(let value): videoMaximumDuration = value
            case .preferredPreset(let value): preferredPreset = value
            case .enableDebugLog: enableDebugLog = true
            }
        }
    }
}

public struct CaptureMediaOption: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let photo = CaptureMediaOption(rawValue: 1 << 0)
    
    public static let video = CaptureMediaOption(rawValue: 1 << 1)
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
