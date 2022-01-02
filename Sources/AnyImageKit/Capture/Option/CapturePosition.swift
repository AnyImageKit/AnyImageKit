//
//  CapturePosition.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/10.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import AVFoundation

/// Preferred position of capture, also a wrapper for AVCaptureDevice.Position.
public enum CapturePosition: RawRepresentable, Equatable {
    
    case front
    case back
    
    public init(rawValue: AVCaptureDevice.Position) {
        switch rawValue {
        case .front:
            self = .front
        case .back:
            self = .back
        default:
            self = .back
        }
    }
    
    public var rawValue: AVCaptureDevice.Position {
        switch self {
        case .front:
            return .front
        case .back:
            return .back
        }
    }
    
    public mutating func toggle() {
        switch self {
        case .back:
            self = .front
        case .front:
            self = .back
        }
    }
}

extension CapturePosition {
    
    var localizedTipsKey: StringConfigKey {
        switch self {
        case .back:
            return .captureSwitchToFrontCamera
        case .front:
            return .captureSwitchToBackCamera
        }
    }
}
