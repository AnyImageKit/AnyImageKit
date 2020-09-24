//
//  TextData.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/17.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class TextData: Codable {
    
    var frame: CGRect = .zero
    var inset: CGFloat = 0
    
    var text: String = ""
    var colorIdx: Int = 0
    var isTextSelected: Bool = true
    var imageData: Data = Data()
    
    var point: CGPoint = .zero
    var scale: CGFloat = 1.0
    var rotation: CGFloat = 0.0
}

extension TextData {
    
    var image: UIImage {
        return UIImage(data: imageData, scale: UIScreen.main.scale) ?? UIImage()
    }
}
