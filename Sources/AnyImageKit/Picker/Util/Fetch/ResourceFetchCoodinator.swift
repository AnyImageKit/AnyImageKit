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
    
    func fetchPhoto(type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion)
    func fetchPhotoData(type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion)
//    func fetchLivePhoto(completion: @escaping ImageResourceLoadCompletion)
//    func fetchVideo(completion: @escaping ImageResourceLoadCompletion)
//    func fetchVideoData(completion: @escaping ImageResourceLoadCompletion)
}
