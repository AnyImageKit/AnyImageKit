//
//  LoadableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/12.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol LoadableResource {
    
    func loadImage(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error>
    func loadImageData(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error>
    func loadLivePhoto(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error>
    func loadGIF(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error>
    func loadVideo(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error>
}

public enum LoadingResult<Success> {
    
    case progress(Double)
    case success(Success)
}

public enum ResourceContentMode: Equatable {
    
    case aspectFill
    case aspectFit
}

extension ResourceContentMode {
    
    var phImageContentMode: PHImageContentMode {
        switch self {
        case .aspectFill:
            return .aspectFill
        case .aspectFit:
            return .aspectFit
        }
    }
}

public struct ResourceLoadOptions {
    
    public let targetSize: CGSize
    public let contentMode: ResourceContentMode
    public let isNetworkAccessAllowed: Bool
    
    public init(targetSize: CGSize,
                contentMode: ResourceContentMode,
                isNetworkAccessAllowed: Bool) {
        self.targetSize = targetSize
        self.contentMode = contentMode
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
    }
}

extension ResourceLoadOptions {
    
    static func library(targetSize: CGSize = PHImageManagerMaximumSize,
                        contentMode: ResourceContentMode = .aspectFill,
                        isNetworkAccessAllowed: Bool = true) -> ResourceLoadOptions {
        return ResourceLoadOptions(targetSize: targetSize,
                                   contentMode: contentMode,
                                   isNetworkAccessAllowed: isNetworkAccessAllowed)
    }
}

public enum ResourceLoadResult {
    // for image
    case thumbnail(UIImage)
    case preview(UIImage)
    case livePhoto(PHLivePhoto)
    case gif(UIImage)
    case original(data: Data, dataUTI: String, orientation: CGImagePropertyOrientation)
    // for video
    case video(avAsset: AVAsset, avAudioMix: AVAudioMix)
}
