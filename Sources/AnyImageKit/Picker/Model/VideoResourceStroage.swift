//
//  VideoResourceStroage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/8/8.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import AVFoundation
import AVKit

public typealias VideoResourceLoadCompletion = (Result<VideoResourceStorage, Error>) -> Void

public struct VideoResourceStorage: IdentifiableResource {
    
    public let identifier: String
    public let type: VideoResourceStorageType
    public let avAsset: AVAsset
}

public enum VideoResourceStorageType: IdentifiableResource {
    
    case playback
    case export
    
    public var identifier: String {
        switch self {
        case .playback:
            return "PLAYBACK"
        case .export:
            return "EXPORT"
        }
    }
}
