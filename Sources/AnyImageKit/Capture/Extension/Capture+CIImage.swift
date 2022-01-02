//
//  Capture+CIIMage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/23.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import CoreImage
import UIKit

extension CIImage {
    
    static func image(size: CGSize, backgroundColor: UIColor) -> CIImage? {
        guard let image = UIImage.image(size: size, backgroundColor: backgroundColor) else { return nil }
        return CIImage(image: image)
    }
}
