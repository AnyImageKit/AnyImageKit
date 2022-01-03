//
//  Editor+AnyImagePage.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/12.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

extension AnyImagePage {
    
    public static let editorPhoto: AnyImagePage = "ANYIMAGEKIT_PAGE_EDITOR_PHOTO"
    
    public static let editorVideo: AnyImagePage = "ANYIMAGEKIT_PAGE_EDITOR_VIDEO"
    
    public static let editorInputText: AnyImagePage = "ANYIMAGEKIT_PAGE_EDITOR_TEXTINPUT"
}

// MARK: - Deprecated
extension AnyImagePage {
    
    @available(*, deprecated, renamed: "editorPhoto", message: "Will be removed in version 1.0, Please use `editorPhoto` instead.")
    public static var photoEditor: AnyImagePage { .editorPhoto }
    
    @available(*, deprecated, renamed: "editorVideo", message: "Will be removed in version 1.0, Please use `editorVideo` instead.")
    public static var videoEditor: AnyImagePage { .editorVideo }
    
    @available(*, deprecated, renamed: "editorInputText", message: "Will be removed in version 1.0, Please use `editorInputText` instead.")
    public static var textInput: AnyImagePage { .editorInputText }
}
