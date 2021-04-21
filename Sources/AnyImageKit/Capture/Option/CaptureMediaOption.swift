//
//  CaptureMediaOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
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
