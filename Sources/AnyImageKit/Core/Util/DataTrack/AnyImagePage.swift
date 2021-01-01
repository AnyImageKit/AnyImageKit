//
//  AnyImagePage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/10/19.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public struct AnyImagePage: Equatable, RawRepresentable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension AnyImagePage: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

extension AnyImagePage {
    
    static let undefined: AnyImagePage = "ANYIMAGEKIT_PAGE_CORE_UNDEFINED"
    
    #if ANYIMAGEKIT_ENABLE_PICKER
    public static let albumPicker: AnyImagePage = "ANYIMAGEKIT_PAGE_PICKER_ALBUM"
    public static let assetPicker: AnyImagePage = "ANYIMAGEKIT_PAGE_PICKER_ASSET"
    public static let photoPreview: AnyImagePage = "ANYIMAGEKIT_PAGE_PICKER_PREVIEW"
    #endif
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    public static let photoEditor: AnyImagePage = "ANYIMAGEKIT_PAGE_EDITOR_PHOTO"
    public static let videoEditor: AnyImagePage = "ANYIMAGEKIT_PAGE_EDITOR_VIDEO"
    public static let textInput: AnyImagePage = "ANYIMAGEKIT_PAGE_EDITOR_TEXTINPUT"
    #endif
    
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    public static let capture: AnyImagePage = "ANYIMAGEKIT_PAGE_CAPTURE"
    #endif
}

public enum AnyImagePageState: Equatable {
    
    case enter
    case leave
}
