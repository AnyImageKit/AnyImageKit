//
//  CachableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/4.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation
import Kingfisher

protocol CachableResource: IdentifiableResource {
    
    var cache: ImageCache { get }
    
    func loadCache(mode: CachedResourceStoreMode) throws -> UIImage
    func loadCacheURL(mode: CachedResourceStoreMode) throws -> URL
    
    func writeCache(image: UIImage, mode: CachedResourceStoreMode) throws
    func writeCache(data: Data, mode: CachedResourceStoreMode) throws
}

enum CachedResourceStoreMode: Equatable {
    
    case thumbnail
    case preview
    case original
}
