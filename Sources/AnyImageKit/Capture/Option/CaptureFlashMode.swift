//
//  CaptureFlashMode.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/10.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import AVFoundation

/// Flash mode, also a wrapper for AVCaptureDevice.FlashMode.
public enum CaptureFlashMode: RawRepresentable, Equatable {
    
    case auto
    case on
    case off
    
    public init(rawValue: AVCaptureDevice.FlashMode) {
        switch rawValue {
        case .auto:
            self = .auto
        case .on:
            self = .on
        case .off:
            self = .off
        @unknown default:
            self = .off
        }
    }
    
    public var rawValue: AVCaptureDevice.FlashMode {
        switch self {
        case .auto:
            return .auto
        case .on:
            return .on
        case .off:
            return .off
        }
    }
    
    public var cameraFlashMode: UIImagePickerController.CameraFlashMode {
        switch self {
        case .auto:
            return .auto
        case .on:
            return .on
        case .off:
            return .off
        }
    }
}
