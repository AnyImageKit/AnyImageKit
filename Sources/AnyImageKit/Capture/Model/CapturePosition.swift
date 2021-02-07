//
//  CapturePosition.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/10.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import AVFoundation

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
    
    var localizedTips: String {
        switch self {
        case .back:
            return BundleHelper.localizedString(key: "SWITCH_TO_FRONT_CAMERA", module: .capture)
        case .front:
            return BundleHelper.localizedString(key: "SWITCH_TO_BACK_CAMERA", module: .capture)
        }
    }
}
