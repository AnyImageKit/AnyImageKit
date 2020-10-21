//
//  Picker+DataTrack.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/10/19.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import Foundation

extension AnyImagePage {
    
    public static let albumPicker: AnyImagePage = "ANYIMAGEKIT_PAGE_PICKER_ALBUM"
    public static let assetPicker: AnyImagePage = "ANYIMAGEKIT_PAGE_PICKER_ASSET"
    public static let photoPreview: AnyImagePage = "ANYIMAGEKIT_PAGE_PICKER_PREVIEW"
}

extension AnyImageEvent {
    
    public static let takePhoto: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_TAKEPHOTO"
    public static let takeVideo: AnyImageEvent = "ANYIMAGEKIT_EVENT_PICKER_TAKEVIDEO"
}
