//
// Editor+UIView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/5.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

extension UIView {
    
    var screenshot: UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { [weak self] (context) in
            return self?.layer.render(in: context.cgContext)
        }
        return image
    }
}

extension UIImageView {
    
    func screenshot(_ imageSize: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = imageSize.width / self.bounds.width
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size, format: format)
        let newImage = renderer.image { [weak self] (context) in
            return self?.layer.render(in: context.cgContext)
        }
        return newImage
    }
}
