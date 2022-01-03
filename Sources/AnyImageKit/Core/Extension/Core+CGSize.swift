//
//  Core+CGSize.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/10.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import CoreGraphics

extension CGSize {
    
    func resizeTo(width: CGFloat) -> CGSize {
        let height = self.height*width/self.width
        return CGSize(width: width, height: height)
    }
    
    func resizeTo(height: CGFloat) -> CGSize {
        let width = self.width*height/self.height
        return CGSize(width: width, height: height)
    }
}
