//
//  Canvas.swift
//  AnyImageKit
//
//  Created by Harley.xk on 2018/4/11.
//
//  The Canvas is a modified version of
//  some classes from Harley's MaLiang project (https://github.com/Harley-xk/MaLiang)
//
//  MIT license
//
//  Copyright (c) 2019 Harley-xk <harley.gb@foxmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

protocol CanvasDelegate: AnyObject {
    
    func canvasDidBeginPen()
    func canvasDidEndPen()
}

protocol CanvasDataSource: AnyObject {
    
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
        let view = UIImageView(frame: .zero)
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
        let animated = lastPenImageView.frame != .zero
        UIView.animate(withDuration: animated ? 0.25 : 0) {
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
        touchesEndedOrCancelled(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEndedOrCancelled(touches)
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
            if state == .end && layerList.count > 0 {
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
    
    private func touchesEndedOrCancelled(_ touches: Set<UITouch>) {
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
