//
//  Core+CGImageSource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/10.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import CoreImage

extension CGImageSource {
    
    var size: CGSize {
        if let properties = CGImageSourceCopyPropertiesAtIndex(self, 0, nil) as? [CFString: Any] {
            if let width = properties[kCGImagePropertyPixelWidth] as? Int, let height = properties[kCGImagePropertyPixelHeight] as? Int {
                return CGSize(width: width, height: height)
            }
        }
        return .zero
    }
}
