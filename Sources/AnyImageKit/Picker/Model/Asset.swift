//
//  Asset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/23.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Photos

public struct Asset<Resource: IdentifiableResource>: IdentifiableResource, CachableResource {
    
    public let resource: Resource
    public let mediaType: MediaType
    
    let stater: AnyImageStater<Resource>
    let fetcher: AnyImageFetcher<Resource>
    let cacher: AnyImageCacher
    
    init(resource: Resource, mediaType: MediaType, stater: AnyImageStater<Resource>, fetcher: AnyImageFetcher<Resource>, cacher: AnyImageCacher) {
        self.resource = resource
        self.mediaType = mediaType
        self.stater = stater
        self.fetcher = fetcher
        self.cacher = cacher
    }
    
    public var identifier: String {
        return resource.identifier
    }
}

extension Asset: CustomStringConvertible {
    
    public var description: String {
        return "Asset<\(Resource.self)> id=\(identifier) mediaType=\(mediaType)\n"
    }
}
