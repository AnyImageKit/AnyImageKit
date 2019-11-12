//
//  TestView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol CanvasDelegate: class {
    
    func canvasDidBeginPen()
    func canvasDidEndPen()
}

protocol CanvasDataSource: class {
    
    func canvasGetScale(_ canvas: Canvas) -> CGFloat
}

class Canvas: UIView {

    weak var delegate: CanvasDelegate?
    weak var dataSource: CanvasDataSource?
    
    var brush = Brush()
    
    private let bezierGenerator = BezierGenerator()
    private var layerList: [CAShapeLayer] = []
    private var lastPoint: CGPoint = .zero
    
    private(set) lazy var lastPenImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        UIView.animate(withDuration: 0.25) {
            self.lastPenImageView.frame = self.bounds
        }
    }
    
    private func setupView() {
        addSubview(lastPenImageView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.preciseLocation(in: self)
        bezierGenerator.begin(with: point)
        pushPoint(point, to: bezierGenerator, state: .begin)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard bezierGenerator.points.count > 0 else { return }
        guard let touch = touches.first else { return }
        let point = touch.preciseLocation(in: self)
        if lastPoint == point { return }
        lastPoint = point
        pushPoint(point, to: bezierGenerator, state: .move)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            bezierGenerator.finish()
            lastPoint = .zero
        }
        
        guard bezierGenerator.points.count > 0 else { return }
        guard let touch = touches.first else { return }
        let point = touch.preciseLocation(in: self)
        pushPoint(point, to: bezierGenerator, state: .end)
    }
}

// MARK: - Public function
extension Canvas {
    
    func reset() {
        for layer in layerList {
            layer.removeFromSuperlayer()
        }
        layerList.removeAll()
    }
}

// MARK: - Private function
extension Canvas {
    
    private func pushPoint(_ point: CGPoint, to bezier: BezierGenerator, state: TouchState) {
        if state == .begin {
            reset()
        }
        defer {
            if state == .end && layerList.count > 3 {
                delegate?.canvasDidEndPen()
            }
        }
        
        let points = bezier.pushPoint(point)
        if points.count < 3 { return }
        delegate?.canvasDidBeginPen()
        
        let scale = dataSource?.canvasGetScale(self) ?? 1.0
        let shapeLayer = layer(of: points, brush: brush, scale: scale)
        layerList.append(shapeLayer)
        self.layer.addSublayer(shapeLayer)
    }
    
    private func layer(of points: [CGPoint], brush: Brush, scale: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath.create(with: points)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.lineWidth = brush.lineWidth / scale
        // Brush
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = brush.color.cgColor
        return shapeLayer
    }
}
