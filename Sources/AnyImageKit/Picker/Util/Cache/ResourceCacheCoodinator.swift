//
//  ResourceCacheCoodinator.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/4.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

protocol ResourceCacheCoodinator {
    
    func isCached(type: ImageResourceStorageType) -> Bool
    func cacheRemove(type: ImageResourceStorageType)
    func cacheWrite(storage: ImageResourceStorage, completion: @escaping ImageResourceLoadCompletion)
    func cacheRead(type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion)
    func cacheReadURL(type: ImageResourceStorageType) -> URL
}
