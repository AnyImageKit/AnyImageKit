//
//  Ex+CGSize.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/10/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import CoreGraphics

extension CGSize {
    
    static func calculate(from originalSize: CGSize, to limitSize: CGSize) -> CGSize {
        let aspectRatio = originalSize.width / originalSize.height
        var width = limitSize.width * aspectRatio
        if aspectRatio > 1.8 {
            width = width * aspectRatio
        }
        if aspectRatio < 0.2 {
            width = width * 0.5
        }
        let height = width / aspectRatio
        return CGSize(width: width, height: height)
    }
}
