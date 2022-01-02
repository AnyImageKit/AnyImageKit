//
//  CaptureCircleView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class CaptureCircleView: UIView {
    
    var color: UIColor = .white
    
    private var style: Style = .small
    
    override init(frame: CGRect) {
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
        let start: CGFloat = -.pi/2
        let end: CGFloat = .pi/2*3
        let radius: CGFloat
        let lineWidth: CGFloat
        switch style {
        case .small:
            radius = 28+2+2
            lineWidth = 2*2
        case .large:
            radius = 28+2+6
            lineWidth = 6*2
        }
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
        context.setLineWidth(lineWidth)
        color.setStroke()
        context.addPath(path.cgPath)
        context.strokePath()
    }
}

// MARK: - Animation
extension CaptureCircleView {
    
    func setStyle(_ style: Style, animated: Bool) {
        self.style = style
        let duration = animated ? 0.25 : 0
        let timingParameters = UICubicTimingParameters(animationCurve: .easeInOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        animator.addAnimations {
            self.setNeedsDisplay()
        }
        animator.startAnimation()
    }
}

extension CaptureCircleView {
    
    enum Style {
        
        case small
        case large
    }
}
