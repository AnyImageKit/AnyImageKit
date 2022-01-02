//
//  CropGridView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/1.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class CropGridView: UIView {

    private(set) lazy var bgLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.opacity = 0
        layer.frame = bounds
        layer.fillRule = .evenOdd
        layer.fillColor = UIColor.black.cgColor
        return layer
    }()
    private lazy var rectLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.opacity = 0
        layer.lineWidth = 1
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    private lazy var lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.opacity = 0
        layer.lineWidth = 1
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    private var cropRect: CGRect = .zero
    
    private var animated: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        layer.addSublayer(bgLayer)
        layer.addSublayer(rectLayer)
        layer.addSublayer(lineLayer)
    }
    
    override func draw(_ rect: CGRect) {
        let bgPath = UIBezierPath(rect: rect)
        let rectPath = UIBezierPath(rect: cropRect)
        bgPath.append(rectPath)
        
        let linePath = UIBezierPath()
        let widthSpace = cropRect.width / 3
        let heightSpace = cropRect.height / 3
        for i in 1...2 {
            let x = widthSpace * CGFloat(i) + cropRect.origin.x
            let y = heightSpace * CGFloat(i) + cropRect.origin.y
            // 竖线
            linePath.move(to: CGPoint(x: x, y: cropRect.origin.y))
            linePath.addLine(to: CGPoint(x: x, y: cropRect.origin.y + cropRect.height))
            // 横线
            linePath.move(to: CGPoint(x: cropRect.origin.x, y: y))
            linePath.addLine(to: CGPoint(x: cropRect.origin.x + cropRect.width, y: y))
        }
        
        if animated {
            animated = false
            let rectAnimation = CABasicAnimation.create(duration: 0.5, fromValue: rectLayer.path, toValue: rectPath.cgPath)
            rectLayer.add(rectAnimation, forKey: "path")
            let lineAnimation = CABasicAnimation.create(duration: 0.5, fromValue: lineLayer.path, toValue: linePath.cgPath)
            lineLayer.add(lineAnimation, forKey: "path")
            let bgAnimation = CABasicAnimation.create(duration: 0.5, fromValue: bgLayer.path, toValue: bgPath.cgPath)
            bgLayer.add(bgAnimation, forKey: "path")
        }
        lineLayer.path = linePath.cgPath
        rectLayer.path = rectPath.cgPath
        bgLayer.path = bgPath.cgPath
    }
}

extension CropGridView {
    
    func setRect(_ rect: CGRect, animated: Bool = false) {
        self.animated = animated
        cropRect = rect
        setNeedsDisplay()
    }
    
    func setHidden(_ hidden: Bool, animated: Bool) {
        bgLayer.opacity = hidden ? 0.0 : 0.8
        rectLayer.opacity = hidden ? 0.0 : 1.0
        lineLayer.opacity = hidden ? 0.0 : 0.7
        
        guard animated else { return }
        let duration = 0.25
        let bgAnimation = CABasicAnimation.create(keyPath: "opacity",
                                                  duration: duration,
                                                  fromValue: hidden ? 0.8 : 1.0,
                                                  toValue: hidden ? 0.0 : 0.8)
        bgLayer.add(bgAnimation, forKey: "opacity")
        let rectAnimation = CABasicAnimation.create(keyPath: "opacity",
                                                    duration: duration,
                                                    fromValue: hidden ? 1.0 : 0.0,
                                                    toValue: hidden ? 0.0 : 1.0)
        rectLayer.add(rectAnimation, forKey: "opacity")
        let lineAnimation = CABasicAnimation.create(keyPath: "opacity",
                                                    duration: duration,
                                                    fromValue: hidden ? 0.7 : 0.0,
                                                    toValue: hidden ? 0.0 : 0.7)
        lineLayer.add(lineAnimation, forKey: "opacity")
    }
}
