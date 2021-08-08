//
//  Asset+ResourceFetchCoodinator.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/25.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

extension Asset: ResourceFetchCoodinator {
    
    func fetchPhoto(type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion) {
        if isCached(type: type) {
            cacheRead(type: type, completion: completion)
        } else {
            
        }
    }
    
    func fetchPhotoData(type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion) {
        
    }
    
//    func fetchLivePhoto(completion: @escaping ImageResourceLoadCompletion) {
//
//    }
//
//    func fetchVideo(completion: @escaping ImageResourceLoadCompletion) {
//
//    }
//
//    func fetchVideoData(completion: @escaping ImageResourceLoadCompletion) {
//
//    }
}
