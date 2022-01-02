//
//  Capture+UIImage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/25.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func image(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        backgroundColor.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}
