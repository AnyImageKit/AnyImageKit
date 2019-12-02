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
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
            let image = renderer.image { [weak self] (context) in
                return self?.layer.render(in: context.cgContext)
            }
            return image
        } else {
            // Fallback on earlier versions
            UIGraphicsBeginImageContextWithOptions(self.frame.size, true, 0.0)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }
    }
}
