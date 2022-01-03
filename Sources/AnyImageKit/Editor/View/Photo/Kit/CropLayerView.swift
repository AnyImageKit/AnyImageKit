//
//  CropLayerView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/28.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class CropLayerView: UIView {

    var path: CGPath? {
        get {
            return cropLayer.path
        } set {
            cropLayer.path = newValue
        }
    }
    var displayRect: CGRect = .zero
    
    /// 用于裁剪后把其他区域以黑色layer盖住
    private(set) lazy var cropLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = bounds
        layer.fillRule = .evenOdd
        layer.fillColor = UIColor.black.cgColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        layer.addSublayer(cropLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cropLayer.frame = bounds
    }
}
