//
//  UIImage.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import MobileCoreServices
import ImageIO

extension UIImage {
    
    static func resize(from image: UIImage, limitSize: CGSize, isExact: Bool) -> UIImage {
        if isExact {
            if image.size.width <= limitSize.width && image.size.height <= limitSize.height { return image }
        } else {
            if image.size.width <= limitSize.width || image.size.height <= limitSize.height { return image }
        }
        let size = calculate(from: image.size, to: limitSize)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    static func resize(from data: Data, limitSize: CGSize, isExact: Bool = false) -> UIImage? {
        guard let image = UIImage(data: data) else { return nil }
        return resize(from: image, limitSize: limitSize, isExact: isExact)
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

extension UIImage {
    
    private struct AssociatedKey {
        
        static var _animatedImageDataKey: UInt8 = 0
        static var _imageSourceKey: UInt8 = 0
    }
    
    var _animatedImageData: Data? {
        get {
            AssociatedObject.get(object: self,
                                 key: &AssociatedKey._animatedImageDataKey,
                                 defaultValue: nil)
        }
        set {
            AssociatedObject.set(object: self,
                                 key: &AssociatedKey._animatedImageDataKey,
                                 value: newValue,
                                 policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var _imageSource: CGImageSource? {
        get {
            AssociatedObject.get(object: self,
                                 key: &AssociatedKey._imageSourceKey,
                                 defaultValue: nil)
        }
        set {
            AssociatedObject.set(object: self,
                                 key: &AssociatedKey._imageSourceKey,
                                 value: newValue,
                                 policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIImage {
    
    static func animatedImage(data: Data, options: ImageCreatingOptions = .init()) -> UIImage? {
        let info: [CFString: Any] = [
            kCGImageSourceShouldCache: true,
            kCGImageSourceTypeIdentifierHint: kUTTypeGIF,
        ]
        
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, info as CFDictionary) else {
            return nil
        }
        
        var image: UIImage?
        if options.preloadAll || options.onlyFirstFrame {
            // Use `images` image if you want to preload all animated data
            guard let animatedImage = GIFAnimatedImage(from: imageSource, for: info, options: options) else {
                return nil
            }
            if options.onlyFirstFrame {
                image = animatedImage.images.first
            } else {
                let duration = options.duration <= 0.0 ? animatedImage.duration : options.duration
                image = .animatedImage(with: animatedImage.images, duration: duration)
            }
            image?._animatedImageData = data
        } else {
            image = UIImage(data: data, scale: options.scale)
            image?._imageSource = imageSource
            image?._animatedImageData = data
        }
        
        return image
    }
}
