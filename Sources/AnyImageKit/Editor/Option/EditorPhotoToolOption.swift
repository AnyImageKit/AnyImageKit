//
//  EditorPhotoToolOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

/// Photo tool option
public enum EditorPhotoToolOption: Equatable, CaseIterable {
    
    case pen
    case text
    case crop
    case mosaic
}

extension EditorPhotoToolOption {
    
    var imageName: String {
        switch self {
        case .pen:
            return "PhotoToolPen"
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
        case .pen:
            return "PEN"
        case .text:
            return "INPUT_TEXT"
        case .crop:
            return "CROP"
        case .mosaic:
            return "MOSAIC"
        }
    }
}
