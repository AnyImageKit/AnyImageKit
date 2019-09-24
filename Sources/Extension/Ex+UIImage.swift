//
//  UIImage.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {
    
    static func resize(from image: UIImage, size: CGSize) -> UIImage {
        if image.size.width <= size.width { return image }
        if image.size.height <= size.height { return image }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    static func resize(from data: Data, size: CGSize) -> UIImage? {
        guard let image = UIImage(data: data) else { return nil }
        return resize(from: image, size: size)
    }
}
