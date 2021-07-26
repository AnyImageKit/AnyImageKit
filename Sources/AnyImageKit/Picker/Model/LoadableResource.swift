//
//  LoadableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/25.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation
import Photos

public typealias MediaResourceLoadCompletion = (Result<MediaResourceStorage, AnyImageError>) -> Void

public enum MediaResourceStorage {
    
    case photo
    case video
    case photoLive
    case photoGIF
}

public protocol LoadableResource: IdentifiableResource {
    
    func loadResource(type: MediaType, completion: MediaResourceLoadCompletion)
}
