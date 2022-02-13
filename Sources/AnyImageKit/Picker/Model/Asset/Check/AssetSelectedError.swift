//
//  AssetSelectedError.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/23.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

enum AssetSelectedError<Resource: IdentifiableResource>: Error {
    
    case maximumOfPhotosOrVideos
    case maximumOfPhotos
    case maximumOfVideos
    case disabled(AssetDisableCheckRule<Resource>)
}
