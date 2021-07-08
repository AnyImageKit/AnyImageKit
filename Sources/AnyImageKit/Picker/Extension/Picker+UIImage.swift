//
//  Picker+UIImage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/8.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImage {
    
    static func animatedImage(data: Data) -> UIImage? {
        return KingfisherWrapper<UIImage>.animatedImage(data: data, options: .init())
    }
}
