//
//  FetchableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/8/8.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public protocol FetchableResource: IdentifiableResource {
    
    associatedtype Resource: FetchableResource
    
    func fetchPhoto(fetcher: AnyImageFetcher<Resource>, type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion)
    func fetchVideo(fetcher: AnyImageFetcher<Resource>, type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion)
}
