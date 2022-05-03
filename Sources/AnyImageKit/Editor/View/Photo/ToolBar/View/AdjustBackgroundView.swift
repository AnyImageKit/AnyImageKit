//
//  AdjustBackgroundView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class AdjustBackgroundView: UIView {

    let positiveColor: UIColor
    let negativeColor: UIColor
    
    // -1 ~ 1
    var value: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    init(positiveColor: UIColor, negativeColor: UIColor) {
        self.positiveColor = positiveColor
        self.negativeColor = negativeColor
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let total = CGFloat.pi * 2
        let startAngle = -(CGFloat.pi / 2)
        let endAngle: CGFloat
        if value > 0 {
            endAngle = value * total + startAngle
        } else {
            endAngle = startAngle - abs(value) * total
        }
        let arcPath = UIBezierPath(arcCenter: rect.center, radius: (rect.width / 2) - 1, startAngle: startAngle, endAngle: endAngle, clockwise: value > 0)
        arcPath.lineWidth = 2.0
        arcPath.lineCapStyle = .round
        arcPath.lineJoinStyle = .round
        (value > 0 ? positiveColor : negativeColor).setStroke()
        arcPath.stroke()
    }
}
