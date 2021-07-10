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
    public let cacher: AnyImageCacher
    
    public init(resource: Resource, mediaType: MediaType, cacher: AnyImageCacher) {
        self.resource = resource
        self.mediaType = mediaType
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
