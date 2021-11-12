//
//  Picker+AnyImageEvent.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

extension AnyImageEvent {
    
    public static let pickerCancel: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_CANCEL"
    public static let pickerDone: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_DONE"
    public static let pickerSelect: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_SELECT"
    public static let pickerSwitchAlbum: AnyImageEvent = "ANYIMAGEKIT_EVENT_SWITCH_ALBUM"
    public static let pickerPreview: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_PREVIEW"
    public static let pickerEdit: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_EDIT"
    public static let pickerOriginalImage: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_ORIGINAL_IMAGE"
    public static let pickerBackInPreview: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_BACK_IN_PREVIEW"
    public static let pickerLimitedLibrary: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_LIMITED_LIBRARY"
    public static let pickerTakePhoto: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_TAKEPHOTO"
    public static let pickerTakeVideo: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_TAKEVIDEO"
}
