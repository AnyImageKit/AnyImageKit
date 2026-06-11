//
//  BrowserOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/10.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//

import UIKit

public struct BrowserOptionsInfo {
    
    /// Theme
    /// - Default: Auto
    public var theme: BrowserTheme = .init()
    
    public var index: Int = 0
    
    /// All resources displayed in the list.
    public var resources: [BrowserResource] = []
    
    public var placeholdImage: UIImage?
    
    public var previewClass: BrowserPreviewController.Type = BrowserPreviewController.self

    public var showStatusBar: Bool = true

    public var singleTapAction: BrowserSingleTapAction = .none
    
    // PHAsset supported types
    public var phAssetSupportedTypes: MediaTypeOption = [.photo, .video, .photoGIF, .photoLive]
    
    public init() {
        
    }
}

public enum BrowserSingleTapAction {
    case none
    case dismiss
}
