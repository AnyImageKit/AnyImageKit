//
//  AnyImageCacher.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/10.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public typealias ImageResourceLoadCompletion = (Result<ImageResourceStorage, Error>) -> Void

public protocol AnyImageCacher {
    
    func isCached(key: String, type: ImageResourceStorageType) -> Bool
    func remove(key: String, type: ImageResourceStorageType)
    func write(key: String, storage: ImageResourceStorage, completion: @escaping ImageResourceLoadCompletion)
    func load(key: String, type: ImageResourceStorageType, completion: @escaping ImageResourceLoadCompletion)
    func loadURL(key: String, type: ImageResourceStorageType) -> URL
}
