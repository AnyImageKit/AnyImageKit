//
//  Editor+AnyImageEvent.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/12.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

extension AnyImageEvent {
    
    // MARK: - Common
    /// UserInfo: [page: (editorPhoto|editorVideo)]
    public static let editorBack: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_BACK"
    
    /// UserInfo: [page: (editorPhoto|editorVideo)]
    public static let editorDone: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_DONE"
    
    /// UserInfo: [page: (editorPhoto|editorVideo)]
    public static let editorCancel: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_CANCEL"
    
    // MARK: - Photo
    
    public static let editorPhotoBrushUndo: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_BRUSH_UNDO"
    
    public static let editorPhotoMosaicUndo: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_MOSAIC_UNDO"
    
    /// UserInfo: [isOn: (true|false)]
    public static let editorPhotoTextSwitch: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_TEXT_SWITCH"
    
    public static let editorPhotoCropRotation: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_CROP_ROTATION"
    
    public static let editorPhotoCropCancel: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_CROP_CANCEL"
    
    public static let editorPhotoCropReset: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_CROP_RESET"
    
    public static let editorPhotoCropDone: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_CROP_DONE"
    
    public static let editorPhotoBrush: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_BRUSH"
    
    public static let editorPhotoMosaic: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_MOSAIC"
    
    public static let editorPhotoText: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_TEXT"
    
    public static let editorPhotoCrop: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_CROP"
    
    // MARK: - Video
    
    /// UserInfo: [isOn: (true|false)] true=play, false=pause
    public static let editorVideoPlayPause: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_VIDEO_PLAY_PAUSE"
}

extension AnyImageEvent {
    
    @available(*, deprecated, renamed: "editorPhotoBrush", message: "Will be removed in version 1.0, Please use `editorPhotoBrush` instead.")
    public static var photoPen: AnyImageEvent { .editorPhotoBrush }
    
    @available(*, deprecated, renamed: "editorPhotoMosaic", message: "Will be removed in version 1.0, Please use `editorPhotoMosaic` instead.")
    public static var photoMosaic: AnyImageEvent { .editorPhotoMosaic }
    
    @available(*, deprecated, renamed: "editorPhotoText", message: "Will be removed in version 1.0, Please use `editorPhotoText` instead.")
    public static var photoText: AnyImageEvent { .editorPhotoText }
    
    @available(*, deprecated, renamed: "editorPhotoCrop", message: "Will be removed in version 1.0, Please use `editorPhotoCrop` instead.")
    public static var photoCrop: AnyImageEvent { .editorPhotoCrop }
}
