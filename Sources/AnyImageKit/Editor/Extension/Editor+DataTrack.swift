//
//  Editor+DataTrack.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/10/21.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import Foundation

extension AnyImagePage {
    
    public static let photoEditor: AnyImagePage = "ANYIMAGEKIT_PAGE_EDITOR_PHOTO"
    public static let videoEditor: AnyImagePage = "ANYIMAGEKIT_PAGE_EDITOR_VIDEO"
    public static let textInput: AnyImagePage = "ANYIMAGEKIT_PAGE_EDITOR_TEXTINPUT"
}

extension AnyImageEvent {
    
    public static let photoPen: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_PEN"
    public static let photoMosaic: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_MOSAIC"
    public static let photoText: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_TEXT"
    public static let photoCrop: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_CROP"
}
