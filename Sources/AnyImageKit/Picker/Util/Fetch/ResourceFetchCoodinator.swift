//
//  ResourceFetchCoodinator.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/10.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

protocol ResourceFetchCoodinator: IdentifiableResource {
    
    associatedtype Resource: IdentifiableResource
    
    var resource: Resource { get }
    var mediaType: MediaType { get }
    func fetchResource(completion: @escaping ImageResourceLoadCompletion)
}
