//
//  AssetDisableCheckRule.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/16.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import Photos

open class AssetDisableCheckRule<Resource: IdentifiableResource>: IdentifiableResource {
    
    open var identifier: String {
        fatalError("You must create subclass and override identifier!")
    }

    open func isDisable(for asset: Asset<Resource>, context: AssetCheckContext<Resource>) -> Bool {
        fatalError("You must create subclass and override this function!")
    }
    
    open func alertMessage(for asset: Asset<Resource>, context: AssetCheckContext<Resource>) -> String {
        fatalError("You must create subclass and override this function!")
    }
}

public final class VideoDurationDisableCheckRuleV2: AssetDisableCheckRule<PHAsset> {
    
    public override var identifier: String {
        return "org.AnyImageKit.AssetDisableCheckRule.Buildin.VideoDuration"
    }
    
    public let minDuration: TimeInterval
    public let maxDuration: TimeInterval
    
    public init(min: TimeInterval, max: TimeInterval) {
        self.minDuration = min
        self.maxDuration = max
    }
    
    public override func isDisable(for asset: Asset<PHAsset>, context: AssetCheckContext<PHAsset>) -> Bool {
        guard asset.mediaType.isVideo else { return false }
        return asset.duration < minDuration || asset.duration > maxDuration
    }
    
    public override func alertMessage(for asset: Asset<PHAsset>, context: AssetCheckContext<PHAsset>) -> String {
        let message = BundleHelper.localizedString(key: "DURATION_OF_SELECTED_VIDEO_RANGE", module: .picker)
        return String(format: message, arguments: [Int(minDuration), Int(maxDuration)])
    }
}

public final class PhotoOrVideoDisableCheckRuleV2: AssetDisableCheckRule<PHAsset> {
    
    public override var identifier: String {
        return "org.AnyImageKit.AssetDisableCheckRule.Buildin.PhotoOrVideo"
    }
    
    public let photoCount: Int
    public let videoCount: Int
    
    public init(photoCount: Int, videoCount: Int) {
        self.photoCount = photoCount
        self.videoCount = videoCount
    }
    
    public override func isDisable(for asset: Asset<PHAsset>, context: AssetCheckContext<PHAsset>) -> Bool {
        guard let first = context.selectedAssets.first else { return false }
        if context.selectedAssets.contains(asset) { return false }
        if (asset.mediaType.isVideo && first.mediaType.isImage) || (asset.mediaType.isImage && first.mediaType.isVideo) {
            return true
        } else {
            if asset.mediaType.isImage {
                return context.selectedAssets.count >= photoCount
            } else {
                return context.selectedAssets.count >= videoCount
            }
        }
    }
    
    public override func alertMessage(for asset: Asset<PHAsset>, context: AssetCheckContext<PHAsset>) -> String {
        guard let first = context.selectedAssets.first else { return "" }
        if (asset.mediaType.isVideo && first.mediaType.isImage) || (asset.mediaType.isImage && first.mediaType.isVideo) {
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
