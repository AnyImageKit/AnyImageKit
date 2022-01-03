//
//  Picker+AnyImagePage.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/12.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

extension AnyImagePage {
    
    public static let pickerAlbum: AnyImagePage = "ANYIMAGEKIT_PAGE_PICKER_ALBUM"
    
    public static let pickerAsset: AnyImagePage = "ANYIMAGEKIT_PAGE_PICKER_ASSET"
    
    public static let pickerPreview: AnyImagePage = "ANYIMAGEKIT_PAGE_PICKER_PREVIEW"
}

// MARK: - Deprecated
extension AnyImagePage {
    
    @available(*, deprecated, renamed: "pickerAlbum", message: "Will be removed in version 1.0, Please use `pickerAlbum` instead.")
    public static var albumPicker: AnyImagePage { .pickerAlbum }
    
    @available(*, deprecated, renamed: "pickerAsset", message: "Will be removed in version 1.0, Please use `pickerAsset` instead.")
    public static var assetPicker: AnyImagePage { .pickerAsset }
    
    @available(*, deprecated, renamed: "pickerPreview", message: "Will be removed in version 1.0, Please use `pickerPreview` instead.")
    public static var photoPreview: AnyImagePage { .pickerPreview }
}
