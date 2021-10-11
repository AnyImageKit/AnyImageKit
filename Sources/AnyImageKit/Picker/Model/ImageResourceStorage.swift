//
//  ImageResourceStorage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

public typealias ResourceLoadProgressHandler = (Double) -> Void
public typealias ImageResourceLoadCompletion = (Result<ImageResourceStorage, Error>) -> Void

public struct ImageResourceStorage: IdentifiableResource {
    
    public let identifier: String
    public let type: ImageResourceStorageType
    public let image: UIImage
    public let data: Data?
    
    init(identifier: String, type: ImageResourceStorageType, image: UIImage, data: Data? = nil) {
        self.identifier = identifier
        self.type = type
        self.image = image
        self.data = data
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
