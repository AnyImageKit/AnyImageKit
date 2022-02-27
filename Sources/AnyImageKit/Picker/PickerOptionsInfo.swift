//
//  PickerOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

// MARK: - PickerOptionsInfo
public struct PickerOptionsInfo {
    
    /// Theme
    /// - Default: auto
    public var theme: PickerTheme = .init(style: .auto)
    
    /// Auto dismiss when select or cancel. If you want to handle by yourself, set `false`.
    ///  - Default: true
    public var autoDismiss: Bool = true
    
    /// Select Limit
    /// - Default: 9
    public var selectLimit: Int = 9
    
    /// Column Number
    /// - Default: 4
    public var columnNumber: Int = 4
    
    /// Auto Calculate Column Number
    /// In iOS column number is `columnNumber`, in iPadOS column number will calculated by device orientation or device size.
    /// - Default: true
    public var autoCalculateColumnNumber: Bool = true
    
    /// - Default: 1200
    public var photoMaxWidth: CGFloat = 1200
    
    /// Max Width for export Large Photo(When User pick original image)
    /// - Default: 1800
    public var largePhotoMaxWidth: CGFloat = 1800
    
    /// Allow Use Original Image, display or hidden button
    /// - Default: false
    public var allowUseOriginalImage: Bool = false
    
    /// Use Original Image
    /// - Default: false
    public var useOriginalImage: Bool = false
    
    /// Album Options
    /// - Default: smart album + user create album
    public var albumOptions: PickerAlbumOption = [.smart, .userCreated, .shared]
    
    /// Select Options
    /// - Default: Photo
    /// - .photoLive and .photoGIF are subtype of .photo and will be treated as a photo when not explicitly indicated, otherwise special handling will be possible (playable & proprietary)
    public var selectOptions: MediaSelectOption = [.photo]
    
    /// Selection Tap Action
    /// - Default: Preview
    public var selectionTapAction: PickerSelectionTapAction = .preview
    
    /// Order by date
    /// - Default: ASC
    public var orderByDate: Sort = .asc
    
    /// Preselect assets
    /// - Default: []
    public var preselectAssets: [String] = []
    
    /// Disable Rules
    /// - Default: []
    public var disableRules: [AssetDisableCheckRule<PHAsset>] = []
    
    /// Enable Debug Log
    /// - Default: false
    public var enableDebugLog: Bool = false
    
    #if ANYIMAGEKIT_ENABLE_EDITOR
    /// Save edited asset when picker dismiss with success
    /// - Default: true
    public var saveEditedAsset: Bool = true
    
    /// Editor Options
    /// - Default: []
    public var editorOptions: PickerEditorOption = []
    
    /// Editor photo option info items
    public var editorPhotoOptions: EditorPhotoOptionsInfo = .init()
    
    /// Editor video option info items
    /*public*/ var editorVideoOptions: EditorVideoOptionsInfo = .init()
    #endif
    
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    /// Capture option info items
    public var captureOptions: CaptureOptionsInfo = .init()
    #endif
    
    #if ANYIMAGEKIT_ENABLE_EDITOR && ANYIMAGEKIT_ENABLE_CAPTURE
    /// Use Same Editor Options In Capture
    /// - Default: true
    public var useSameEditorOptionsInCapture: Bool = true
    #endif
    
    public init() {
        #if ANYIMAGEKIT_ENABLE_CAPTURE
        captureOptions.mediaOptions = []
        #endif
    }
}

// MARK: - Album Options
public struct PickerAlbumOption: OptionSet {
    
    /// Smart Album, managed by system
    public static let smart = PickerAlbumOption(rawValue: 1 << 0)
    /// User Created Album
    public static let userCreated = PickerAlbumOption(rawValue: 1 << 1)
    /// Shared Album
    public static let shared = PickerAlbumOption(rawValue: 1 << 2)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

// MARK: - Editor Options
public struct PickerEditorOption: OptionSet {
    
    /// Photo
    public static let photo = PickerEditorOption(rawValue: 1 << 0)
    /// Video: - TODO
    /*public*/ static let video = PickerEditorOption(rawValue: 1 << 1)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

// MARK: - Picker Selection Tap Action
public enum PickerSelectionTapAction: Equatable {
    
    /// Preview
    /// - Default value
    case preview
    /// Quick pick
    /// - It will select photo instead of show preview controller when you click photo on asset picker controller
    case quickPick
    /// Open editor
    /// - It will open Editor instead of show preview controller when you click photo on asset picker controller
    case openEditor
}

extension PickerSelectionTapAction {
    
    var hideToolBar: Bool {
        switch self {
        case .quickPick, .openEditor:
            return true
        default:
            return false
        }
    }
}
