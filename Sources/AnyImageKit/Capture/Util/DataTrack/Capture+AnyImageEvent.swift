//
//  Capture+AnyImageEvent.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/12.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

extension AnyImageEvent {
    
    public static let capturePhoto: AnyImageEvent = "ANYIMAGEKIT_EVENT_CAPTURE_PHOTO"
    public static let captureVideo: AnyImageEvent = "ANYIMAGEKIT_EVENT_CAPTURE_VIDEO"
    public static let captureCancel: AnyImageEvent = "ANYIMAGEKIT_EVENT_CAPTURE_CANCEL"
    public static let captureSwitchCamera: AnyImageEvent = "ANYIMAGEKIT_EVENT_CAPTURE_SWITCH_CAMERA"
}
