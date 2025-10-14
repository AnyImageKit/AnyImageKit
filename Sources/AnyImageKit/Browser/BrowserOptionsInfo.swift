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
    public var theme: BrowserTheme = .init(style: .auto)
    
    public var index: Int = 0
    
    /// All resources displayed in the list.
    public var resources: [BrowserResource] = []
    
    public var placeholdImage: UIImage?
    
    public var previewClass: BrowserPreviewController.Type = BrowserPreviewController.self
    
    public var relatedView: ((_ index: Int) -> UIView?)? = nil
    
    public var showStatusBar: Bool = false
    
    // ph asset support type
    public var supportType: PickerSelectOption = [.photo, .video, .photoGIF, .photoLive]
}
