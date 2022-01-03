//
//  CaptureMediaOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

/// Media options for capture.
public struct CaptureMediaOption: OptionSet {
    
    public static let photo = CaptureMediaOption(rawValue: 1 << 0)
    
    public static let video = CaptureMediaOption(rawValue: 1 << 1)
    
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension CaptureMediaOption {
    
    var localizedTipsKey: StringConfigKey {
        if contains(.photo) && contains(.video) {
            return .captureHoldForVideoTapForPhoto
        }
        if contains(.photo) {
            return .captureTapForPhoto
        }
        if contains(.video) {
            return .captureHoldForVideo
        }
        return StringConfigKey(rawValue: "")
    }
}
