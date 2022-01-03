//
//  EditorPhotoToolOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
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
    
    var iconKey: EditorTheme.IconConfigKey {
        switch self {
        case .brush:
            return .photoToolBrush
        case .text:
            return .photoToolText
        case .crop:
            return .photoToolCrop
        case .mosaic:
            return .photoToolMosaic
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
    
    var stringKey: StringConfigKey {
        switch self {
        case .brush:
            return .editorBrush
        case .text:
            return .editorInputText
        case .crop:
            return .editorCrop
        case .mosaic:
            return .editorMosaic
        }
    }
}

// MARK: - Deprecated
extension EditorPhotoToolOption {
    
    @available(*, deprecated, renamed: "brush", message: "Will be removed in version 1.0, Please use `.brush` instead.")
    public static var pen: EditorPhotoToolOption {
        return .brush
    }
}
