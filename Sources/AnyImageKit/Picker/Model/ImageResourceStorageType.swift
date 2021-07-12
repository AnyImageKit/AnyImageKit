//
//  ImageResourceStorageType.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

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
