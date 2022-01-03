//
//  Editor+UIView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/5.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension UIView {
    
    func screenshot(_ imageSize: CGSize = .zero) -> UIImage {
        let size = CGSize(width: self.bounds.size.width.roundTo(places: 5), height: self.bounds.size.height.roundTo(places: 5))
        let renderer: UIGraphicsImageRenderer
        if imageSize == .zero {
            renderer = UIGraphicsImageRenderer(size: size)
        } else {
            let format = UIGraphicsImageRendererFormat()
            format.scale = imageSize.width / size.width
            renderer = UIGraphicsImageRenderer(size: size, format: format)
        }
        return renderer.image { [weak self] context in
            self?.layer.render(in: context.cgContext)
        }
    }
}
