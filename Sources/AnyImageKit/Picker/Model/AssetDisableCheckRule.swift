//
//  AssetDisableCheckRule.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/11/17.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public protocol AssetDisableCheckRule {
    
    /// Disable current asset
    /// - Parameters:
    ///   - asset: Current asset
    ///   - assetList: Selected assets
    func isDisable(for asset: Asset, assetList: [Asset]) -> Bool
    
    /// Alert message when select disabled asset
    /// - Parameters:
    ///   - asset: Current asset
    ///   - assetList: Selected assets
    func alertMessage(for asset: Asset, assetList: [Asset]) -> String
}

public struct VideoDurationDisableCheckRule: AssetDisableCheckRule {
    
    public let minDuration: TimeInterval
    public let maxDuration: TimeInterval
    
    public init(min: TimeInterval, max: TimeInterval) {
        self.minDuration = min
        self.maxDuration = max
    }
    
    public func isDisable(for asset: Asset, assetList: [Asset]) -> Bool {
        guard asset.mediaType.isVideo else { return false }
        return asset.duration < minDuration || asset.duration > maxDuration
    }
    
    public func alertMessage(for asset: Asset, assetList: [Asset]) -> String {
        let message = BundleHelper.localizedString(key: "DURATION_OF_SELECTED_VIDEO_RANGE", module: .picker)
        return String(format: message, arguments: [Int(minDuration), Int(maxDuration)])
    }
}

public struct PhotoOrVideoDisableCheckRule: AssetDisableCheckRule {
    
    public let photoCount: Int
    public let videoCount: Int
    
    public init(photoCount: Int, videoCount: Int) {
        self.photoCount = photoCount
        self.videoCount = videoCount
    }
    
    public func isDisable(for asset: Asset, assetList: [Asset]) -> Bool {
        guard let firstAsset = assetList.first else { return false }
        if assetList.contains(asset) { return false }
        if (asset.mediaType.isVideo && firstAsset.mediaType.isImage)
            || (asset.mediaType.isImage && firstAsset.mediaType.isVideo) {
            return true
        } else {
            if asset.mediaType.isImage {
                return assetList.count >= photoCount
            } else {
                return assetList.count >= videoCount
            }
        }
    }
    
    public func alertMessage(for asset: Asset, assetList: [Asset]) -> String {
        guard let firstAsset = assetList.first else { return "" }
        if (asset.mediaType.isVideo && firstAsset.mediaType.isImage)
            || (asset.mediaType.isImage && firstAsset.mediaType.isVideo) {
            return BundleHelper.localizedString(key: "CANNOT_SELECT_PHOTOS_AND_VIDEOS_AT_SAME_TIME", module: .picker)
        } else {
            if asset.mediaType.isImage {
                return String(format: BundleHelper.localizedString(key: "SELECT_A_MAXIMUM_OF_PHOTOS", module: .picker), photoCount)
            } else {
                return String(format: BundleHelper.localizedString(key: "SELECT_A_MAXIMUM_OF_VIDEOS", module: .picker), videoCount)
            }
        }
    }
}
