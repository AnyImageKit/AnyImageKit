//
//  FetchableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/10.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

protocol FetchableResource: IdentifiableResource {
    
    associatedtype Resource: MediaLoadableResource
    
    var resource: Resource { get }
    var fetcher: AnyImageFetcher<Resource> { get }
    func loadResource(type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion)
}

extension FetchableResource {
    
    
}
