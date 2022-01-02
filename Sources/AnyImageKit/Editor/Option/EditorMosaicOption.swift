//
//  EditorMosaicOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

/// Mosaic option
public enum EditorMosaicOption: Equatable, Hashable {
    
    /// Default mosaic.
    /// Blurring the original image.
    case `default`
    
    /// Custom mosaic.
    ///
    /// The principle of mosaic is to superimpose a transparent mosaic image on the original image.
    /// After the user gestures slip, the sliding part is displayed.
    /// Based on that you can customize your own mosaic.
    ///
    /// icon: Image on mosaic tool bar, it will use mosaic image as icon image if icon image is nil.
    ///
    /// mosaic: Custom mosaic image.
    case custom(icon: UIImage?, mosaic: UIImage)
    
    public static var colorful: EditorMosaicOption {
        return .custom(icon: nil, mosaic: BundleHelper.image(named: "CustomMosaic", module: .editor)!)
    }
}

extension EditorMosaicOption: CaseIterable {
    
    public static var allCases: [EditorMosaicOption] {
        return [.default, .colorful]
    }
}
