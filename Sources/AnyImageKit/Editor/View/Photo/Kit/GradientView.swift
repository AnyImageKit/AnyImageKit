//
//  GradientView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/10/21.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class GradientView: UIView {
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }
}
