//
//  Asset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/23.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation
import Photos

public struct Asset<Resource: IdentifiableResource> {
    
    public let resource: Resource
    public let mediaType: MediaType
    
    public init(resource: Resource, mediaType: MediaType) {
        self.resource = resource
        self.mediaType = mediaType
    }
}

extension Asset: IdentifiableResource {
    
    public var identifier: String {
        return resource.identifier
    }
}

//extension Asset: CachableResource {
//    
//    
//}

extension Asset: CustomStringConvertible {
    
    public var description: String {
        return "Asset<\(Resource.self)> id=\(identifier) mediaType=\(mediaType)\n"
    }
}
