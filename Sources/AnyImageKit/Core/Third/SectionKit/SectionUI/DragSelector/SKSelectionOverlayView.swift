//
//  SelectionOverlay.swift
//  Test
//
//  Created by linhey on 8/29/25.
//

import UIKit

// MARK: - 选择覆盖层
public class SKSelectionOverlayView: UIView {
    
    public let shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.blue.withAlphaComponent(0.2).cgColor
        layer.strokeColor = UIColor.blue.withAlphaComponent(0.5).cgColor
        layer.lineWidth = 1
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    private func setupLayer() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        layer.addSublayer(shapeLayer)
    }
    
    func updateSelectionRect(_ rect: CGRect) {
        // 使用 CATransaction 来避免隐式动画
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        frame = rect
        shapeLayer.path = UIBezierPath(rect: bounds).cgPath
        CATransaction.commit()
    }
}
