//
//  ImageResourceStorage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

public typealias ImageResourceLoadCompletion = (Result<ImageResourceStorage, Error>) -> Void

public enum ImageResourceStorage {
    
    case thumbnail(UIImage)
    case preview(UIImage)
    case original(UIImage, Data?)
    
    init(type: ImageResourceStorageType, image: UIImage, data: Data?) {
        switch type {
        case .thumbnail:
            self = .thumbnail(image)
        case .preview:
            self = .preview(image)
        case .original:
            self = .original(image, data)
        }
    }
    
    public var type: ImageResourceStorageType {
        switch self {
        case .thumbnail:
            return .thumbnail
        case .preview:
            return .preview
        case .original:
            return .original
        }
    }
    
    public var image: UIImage {
        switch self {
        case .thumbnail(let image):
            return image
        case .preview(let image):
            return image
        case .original(let image, _):
            return image
        }
    }
}

public enum ImageResourceStorageType: IdentifiableResource {
    
    case thumbnail
    case preview
    case original
    
    public var identifier: String {
        switch self {
        case .thumbnail:
            return "THUMBNAIL"
        case .preview:
            return "PREVIEW"
        case .original:
            return "ORIGINAL"
        }
    }
}
