//
//  AssetDisableCheckRule.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/11/17.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import Foundation

public protocol AssetDisableCheckRule {
    
    func check(asset: Asset) -> Bool
    func alertMessage(for asset: Asset) -> String
}

public struct VideoDurationDisableCheckRule: AssetDisableCheckRule {
    
    public let minDuration: TimeInterval
    public let maxDuration: TimeInterval
    
    public init(min: TimeInterval, max: TimeInterval) {
        self.minDuration = min
        self.maxDuration = max
    }
    
    public func check(asset: Asset) -> Bool {
        return asset.duration < minDuration || asset.duration > maxDuration
    }
    
    public func alertMessage(for asset: Asset) -> String {
        return "选取视频长度应在\(10)-\(60)秒之间"
    }
}
