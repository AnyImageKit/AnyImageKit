//
//  CropData.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/5.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

struct CropData: Codable, Equatable {
    
    var cropOptionIdx: Int = 0
    var didCrop: Bool = false
    var rect: CGRect = .zero
    var zoomScale: CGFloat = 1.0
    var contentSize: CGSize = .zero
    var contentOffset: CGPoint = .zero
    var imageViewFrame: CGRect = .zero
}
