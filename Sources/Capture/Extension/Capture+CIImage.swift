//
//  Capture+CIIMage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/23.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import CoreImage
import UIKit

extension CIImage {
    
    static func createBlackImage(with size: CGSize) -> CIImage {        
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return .empty() }
        UIColor.black.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return .empty() }
        guard let ciImage = CIImage(image: image) else { return .empty() }
        return ciImage
    }
}
