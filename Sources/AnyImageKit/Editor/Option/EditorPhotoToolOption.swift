//
//  EditorPhotoToolOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

/// Photo tool option
public enum EditorPhotoToolOption: Equatable {
    
    case brush
    case text
    case crop
    case mosaic
}

extension EditorPhotoToolOption: CaseIterable {
    
    public static var allCases: [EditorPhotoToolOption] {
        return [.brush, .text, .crop, .mosaic]
    }
}

extension EditorPhotoToolOption {
    
    var imageName: String {
        switch self {
        case .brush:
            return "PhotoToolBrush"
        case .text:
            return "PhotoToolText"
        case .crop:
            return "PhotoToolCrop"
        case .mosaic:
            return "PhotoToolMosaic"
        }
    }
}

extension EditorPhotoToolOption: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .brush:
            return "BRUSH"
        case .text:
            return "INPUT_TEXT"
        case .crop:
            return "CROP"
        case .mosaic:
            return "MOSAIC"
        }
    }
}

// MARK: - Deprecated
extension EditorPhotoToolOption {
    
    @available(*, deprecated, message: "Will be removed in version 1.0, Please use `.brush` instead.")
    public static var pen: EditorPhotoToolOption {
        return .brush
    }
}
