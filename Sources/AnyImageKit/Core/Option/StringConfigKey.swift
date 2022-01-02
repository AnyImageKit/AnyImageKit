//
//  StringConfigKey.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/6/25.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public struct StringConfigKey: Hashable {

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension StringConfigKey {
    
    public static let ok          = StringConfigKey(rawValue: "OK")
    public static let back        = StringConfigKey(rawValue: "BACK")
    public static let done        = StringConfigKey(rawValue: "DONE")
    public static let edit        = StringConfigKey(rawValue: "EDIT")
    public static let alert       = StringConfigKey(rawValue: "ALERT")
    public static let cancel      = StringConfigKey(rawValue: "CANCEL")
    public static let preview     = StringConfigKey(rawValue: "PREVIEW")
    public static let photos      = StringConfigKey(rawValue: "PHOTOS")
    public static let camera      = StringConfigKey(rawValue: "CAMERA")
    public static let microphone  = StringConfigKey(rawValue: "MICROPHONE")
    public static let settings    = StringConfigKey(rawValue: "SETTINGS")
    
    public static let photo       = StringConfigKey(rawValue: "PHOTO")
    public static let video       = StringConfigKey(rawValue: "VIDEO")
    public static let livePhoto   = StringConfigKey(rawValue: "LIVE_PHOTO")
    public static let loading     = StringConfigKey(rawValue: "LOADING")

    public static let undo        = StringConfigKey(rawValue: "UNDO")
    public static let play        = StringConfigKey(rawValue: "PLAY")
    public static let pause       = StringConfigKey(rawValue: "PAUSE")
    public static let reset       = StringConfigKey(rawValue: "RESET")
    public static let downloading = StringConfigKey(rawValue: "DOWNLOADING")

    public static let goToSettings               = StringConfigKey(rawValue: "GO_TO_SETTINGS")
    public static let permissionIsDisabled       = StringConfigKey(rawValue: "PERMISSION_IS_DISABLED")
    public static let noPhotosPermissionTips     = StringConfigKey(rawValue: "NO_PHOTOS_PERMISSION_TIPS")
    public static let noCameraPermissionTips     = StringConfigKey(rawValue: "NO_CAMERA_PERMISSION_TIPS")
    public static let noMicrophonePermissionTips = StringConfigKey(rawValue: "NO_MICROPHONE_PERMISSION_TIPS")
}
