//
//  Core+UIImage.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/20.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
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
        let size = calculate(from: image.size, to: limitSize)
        guard let pngData = image.pngData() else { return image }
        guard let resized = resize(from: pngData, limitSize: size) else { return image }
        return resized
    }
    
    static func resize(from data: Data, limitSize: CGSize) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        
        let maxDimensionInPixels = max(limitSize.width, limitSize.height)
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        return UIImage(cgImage: downsampledImage, scale: 1.0, orientation: .up)
    }
    
    private static func calculate(from originalSize: CGSize, to limitSize: CGSize) -> CGSize {
        if originalSize.width >= originalSize.height {
            let width = limitSize.width
            let height = originalSize.height*width/originalSize.width
            return CGSize(width: width, height: height)
        } else {
            let height = limitSize.height
            let width = originalSize.width*height/originalSize.height
            return CGSize(width: width, height: height)
        }
    }
}
