//
//  CaptureRecordView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class CaptureRecordView: UIView {
    
    var color: UIColor = .white
    var recordColor: UIColor = .red
    
    private var style: Style = .normal
    
    private lazy var buttonLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        layer.addSublayer(buttonLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buttonLayer.frame = bounds
        setStyle(style, animated: false)
    }
}

// MARK: - Animation
extension CaptureRecordView {
    
    func setStyle(_ style: Style, animated: Bool) {
        let duration = animated ? 0.25 : 0
        let newPath: UIBezierPath
        let width: CGFloat
        let cornerRadius: CGFloat
        let color: CGColor
        switch style {
        case .normal:
            width = 54
            cornerRadius = width/2
            color = self.color.cgColor
        case .recording:
            width = 30
            cornerRadius = 4
            color = self.recordColor.cgColor
        }
        
        let rect = CGRect(origin: CGPoint(x: (bounds.width-width)/2, y: (bounds.height-width)/2), size: CGSize(width: width, height: width))
        newPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.fromValue = buttonLayer.path
        animation.toValue = newPath
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        buttonLayer.add(animation, forKey: "animation")
        buttonLayer.fillColor = color
        buttonLayer.path = newPath.cgPath
        
        self.style = style
    }
}

extension CaptureRecordView {
    
    enum Style {
        
        case normal
        case recording
    }
}
