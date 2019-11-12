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
