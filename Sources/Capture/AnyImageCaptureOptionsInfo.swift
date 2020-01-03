//
//  AnyImageCaptureOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public enum AnyImageCaptureOptionsInfoItem: AnyImageOptionsInfoItem {
    /// 主题色
    /// 默认：green
    case tintColor(UIColor)
    case mediaOptions(AnyImageCaptureMediaOptions)
    case photoAspectRatio(AnyImageCaptureAspectRatio)
    case preferredPositions([AVCaptureDevice.Position])
    case flashMode(AVCaptureDevice.FlashMode)
    case videoMaximumDuration(TimeInterval)
    
    /// 启用调试日志
    /// 默认：false
    case enableDebugLog
}

public struct AnyImageCaptureOptionsInfo: Equatable {
    
    public var tintColor: UIColor = UIColor.color(hex: 0x57BE6A)
    public var mediaOptions: AnyImageCaptureMediaOptions = [.photo, .video]
    public var photoAspectRatio: AnyImageCaptureAspectRatio = .ratio4x3
    public var preferredPositions: [AVCaptureDevice.Position] = [.back, .front]
    public var flashMode: AVCaptureDevice.FlashMode = .auto
    public var videoMaximumDuration: TimeInterval = 30
    public var enableDebugLog: Bool = false
    
    public init(_ info: [AnyImageCaptureOptionsInfoItem] = []) {
        for option in info {
            switch option {
            case .tintColor(let value): tintColor = value
            case .mediaOptions(let value): mediaOptions = value
            case .photoAspectRatio(let value): photoAspectRatio = value
            case .preferredPositions(let value): preferredPositions = value
            case .flashMode(let value): flashMode = value
            case .videoMaximumDuration(let value): videoMaximumDuration = value
            case .enableDebugLog: enableDebugLog = true
            }
        }
    }
}

public struct AnyImageCaptureMediaOptions: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let photo = AnyImageCaptureMediaOptions(rawValue: 1 << 0)
    
    public static let video = AnyImageCaptureMediaOptions(rawValue: 1 << 1)
}

public enum AnyImageCaptureAspectRatio: Equatable {
    
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
}
