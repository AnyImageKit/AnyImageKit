//
//  Core+UIImage.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/20.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {
    
    static func resize(from image: UIImage, limitSize: CGSize, isExact: Bool) -> UIImage {
        if isExact {
            if image.size.width <= limitSize.width && image.size.height <= limitSize.height { return image }
        } else {
            if image.size.width <= limitSize.width || image.size.height <= limitSize.height { return image }
        }
        guard let pngData = image.pngData() else { return image }
        guard let resized = resize(from: pngData, limitSize: limitSize) else { return image }
        return resized
    }
    
    static func resize(from data: Data, limitSize: CGSize) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        let size = calculate(from: imageSource.size, to: limitSize)
        let maxDimensionInPixels = max(size.width, size.height)
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels,
        ]
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: downsampledImage, scale: 1.0, orientation: .up)
    }
    
    private static func calculate(from originalSize: CGSize, to limitSize: CGSize) -> CGSize {
        let aspectRatioLimit: CGFloat = 2.5
        if originalSize.width >= originalSize.height {
            let aspectRatio = originalSize.width/originalSize.height
            if aspectRatio >= aspectRatioLimit { // long picture
                let height = min(originalSize.height, limitSize.height)
                return originalSize.resizeTo(height: height)
            } else {
                let width = limitSize.width
                return originalSize.resizeTo(width: width)
            }
        } else {
            let aspectRatio = originalSize.height/originalSize.width
            if aspectRatio >= aspectRatioLimit { // long picture
                let width = min(originalSize.width, limitSize.width)
                return originalSize.resizeTo(width: width)
            } else {
                let height = limitSize.height
                return originalSize.resizeTo(height: height)
            }
        }
    }
}
