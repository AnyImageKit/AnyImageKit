//
//  Editor+AnyImageEvent.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

extension AnyImageEvent {
    
    // MARK: - Common
    public static let editorBack: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_BACK"
    public static let editorCancel: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_CANCEL"
    public static let editorDone: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_DONE"
    
    // MARK: - Photo
    public static let editorPhotoBrushUndo: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_BRUSH_UNDO"
    public static let editorPhotoMosaicUndo: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_PHOTO_MOSAIC_UNDO"
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
    public static let editorVideoPlayPluse: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_VIDEO_PLAY_PLUSE"
//    public static let editorVideoCropLeft: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_VIDEO_CROP_LEFT"
//    public static let editorVideoCropRight: AnyImageEvent = "ANYIMAGEKIT_EVENT_EDITOR_VIDEO_CROP_RIGHT"
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
