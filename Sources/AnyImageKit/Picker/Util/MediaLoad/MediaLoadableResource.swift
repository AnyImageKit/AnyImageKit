//
//  MediaLoadableResource.swift
//  MediaLoadableResource
//
//  Created by 刘栋 on 2021/7/19.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public protocol MediaLoadableResource: IdentifiableResource {
    
    func loadResource(mediaType: MediaType, resourceType: ImageResourceStorageType, completion: ImageResourceLoadCompletion)
}
