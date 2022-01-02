//
//  CaptureOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import AVFoundation

public struct CaptureOptionsInfo {
    
    /// Theme
    public var theme: CaptureTheme = .init()
    
    /// Media options for capture.
    ///
    /// You can tap to take photo and hold to take video.
    ///
    /// - Default: [photo, video]
    public var mediaOptions: CaptureMediaOption = [.photo, .video]
    
    /// The ratio of take photo.
    ///
    /// - Note: Invalid on iPad.
    ///
    /// - Default: 4:3
    public var photoAspectRatio: CaptureAspectRatio = .ratio4x3
    
    /// Preferred position of capture.
    ///
    /// The camera of the first element of position will be used when open capture
    /// Eg. [back] Capture will always use back camera, user CAN NOT switch camera.
    /// Eg. [back, front] The back camera will be used when open capture, then user can switch to front camera.
    ///
    /// - Note: On iPad, Capture CAN NOT limit user to switch the camera even though you set one position only. For example set [back] in this case. Capture will use back camera at the first time, then user still can switch camera.
    ///
    /// - Default: [back, front]
    public var preferredPositions: [CapturePosition] = [.back, .front]
    
    /// Flash Mode.
    /// - Default: off
    public var flashMode: CaptureFlashMode = .off
    
    /// The maximum time(second) of the video can be recorded.
    /// - Default: 20 second
    public var videoMaximumDuration: TimeInterval = 20
    
    /// The preferred presets of the camera.
    ///
    /// Capture will check camera's support formats and chose the best one form `preferredPresets`
    ///
    /// - Note: Invalid on iPad.
    /// - Default: [hd1920x1080_60, hd1280x720_60, hd1920x1080_30, hd1280x720_30]
    public var preferredPresets: [CapturePreset] = CapturePreset.createPresets(enableHighResolution: false, enableHighFrameRate: true)
    
    /// Enable debug log
    /// - Default: false
    public var enableDebugLog: Bool = false
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    /// Editor photo options info, used for editor after take photo.
    /// - Note: Invalid on iPad.
    public var editorPhotoOptions: EditorPhotoOptionsInfo = .init()
    
    /// Editor video options info, used for editor after take video.
    /// - Note: Invalid on iPad.
    public var editorVideoOptions: EditorVideoOptionsInfo = .init()
    #endif
    
    public init() { }
}

// MARK: - Deprecated
extension CaptureOptionsInfo {
    
    @available(*, deprecated, message: "Will be removed in version 1.0, Please set `theme[color: .primary]` instead.")
    public var tintColor: UIColor {
        get { theme[color: .primary] }
        set { theme[color: .primary] = newValue }
    }
}
