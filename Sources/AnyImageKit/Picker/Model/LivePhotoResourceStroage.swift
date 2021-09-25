//
//  LivePhotoResourceStroage.swift
//  LivePhotoResourceStroage
//
//  Created by 刘栋 on 2021/8/29.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Photos

public typealias LivePhotoResourceLoadCompletion = (Result<LivePhotoResourceStroage, Error>) -> Void

public struct LivePhotoResourceStroage {
    
    public let identifier: String
    public let livePhoto: PHLivePhoto
}

public enum LivePhotoResourceStorageType: IdentifiableResource {
    
    case system
    
    public var identifier: String {
        switch self {
        case .system:
            return "SYSTEM"
        }
    }
}
