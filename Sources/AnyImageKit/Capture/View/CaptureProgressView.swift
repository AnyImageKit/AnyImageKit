//
//  CaptureProgressView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/9.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class CaptureProgressView: UIView {
    
    private var style: Style = .progress(0.0)
    
    private lazy var animationLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        let lineWidth: CGFloat = 4
        let size = CGSize(width: 64, height: 64)
        path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                    radius: size.width / 2,
                    startAngle: -(.pi / 2),
                    endAngle: .pi + .pi / 2,
                    clockwise: true)
        layer.fillColor = nil
        layer.strokeColor = options.theme[color: .primary].cgColor
        layer.lineWidth = lineWidth
        layer.backgroundColor = nil
        layer.path = path.cgPath
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return layer
    }()
    
    private let options: CaptureOptionsInfo
    
    init(frame: CGRect, options: CaptureOptionsInfo) {
        self.options = options
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        
        let center: CGPoint = CGPoint(x: rect.midX, y: rect.midY)
        let lineWidth: CGFloat = 4
        
        switch style {
        case .progress(let progress):
            if progress > 0.0 {
                let radius: CGFloat = 28+2+12-lineWidth/2
                let start: CGFloat = -.pi/2
                let end: CGFloat = start + .pi * 2.0 * progress
                let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
                context.setLineWidth(lineWidth)
                options.theme[color: .primary].setStroke()
                context.addPath(path.cgPath)
                context.strokePath()
            }
        case .processing:
            animationLayer.frame.origin = CGPoint(x: (rect.width-64)/2, y: (rect.height-64)/2)
        }
    }
}

// MARK: - Animation
extension CaptureProgressView {
    
    func setProgress(_ progress: CGFloat) {
        self.style = .progress(progress)
        setNeedsDisplay()
    }
    
    func startProcessing() {
        self.style = .processing
        setNeedsDisplay()
        
        let groupAnimation = createAnimationGroup()
        animationLayer.add(groupAnimation, forKey: "animation")
        layer.addSublayer(animationLayer)
    }
    
    func stopProcessing() {
        animationLayer.removeAnimation(forKey: "animation")
        animationLayer.removeFromSuperlayer()
    }
    
    private func createAnimationGroup() -> CAAnimationGroup {
        let beginTime: Double = 0.5
        let strokeStartDuration: Double = 1.2
        let strokeEndDuration: Double = 0.7

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.byValue = Float.pi * 2
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)

        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.duration = strokeEndDuration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1.0

        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.duration = strokeStartDuration
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1.0
        strokeStartAnimation.beginTime = beginTime

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotationAnimation, strokeEndAnimation, strokeStartAnimation]
        groupAnimation.duration = strokeStartDuration + beginTime
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        
        return groupAnimation
    }
}

extension CaptureProgressView {
    
    enum Style {
        
        case progress(CGFloat)
        case processing
    }
}
