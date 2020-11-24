//
//  DryDrawingView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/9.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

class DryDrawingView : UIView {
    
    private var bezierPath: UIBezierPath = UIBezierPath()
    private var step = 0
    private var points: [CGPoint] = Array(repeating: CGPoint(), count: 3)
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func willBeginPan(path: UIBezierPath) { }
    func panning(path: UIBezierPath) { }
    func didFinishPan(path: UIBezierPath) { }
    
    // MARK: - Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchPoint = touch.preciseLocation(in: self)
        bezierPath = UIBezierPath()
        willBeginPan(path: bezierPath)
        step = 0
        points.removeAll()
        points.append(touchPoint)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        draw(touches, finish: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        draw(touches, finish: true)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draw(touches, finish: true)
    }
    
    private func draw(_ touches: Set<UITouch>, finish: Bool) {
        defer {
            if finish {
                step = 0
                points.removeAll()
                didFinishPan(path: bezierPath)
            } else {
                panning(path: bezierPath)
            }
        }
        
        guard let touch = touches.first else { return }
        let touchPoint = touch.preciseLocation(in: self)
        let pathPoints = pushPoints(touchPoint)
        if pathPoints.count >= 3 {
            bezierPath.move(to: pathPoints.first!)
            for i in 1..<pathPoints.count {
                bezierPath.addLine(to: pathPoints[i])
            }
        }
        setNeedsDisplay()
    }
    
    private func pushPoints(_ point: CGPoint) -> [CGPoint] {
        if point == points.last {
            return []
        }
        points.append(point)
        if points.count < 3 {
            return []
        }
        step += 1
        return genericPathPoints()
    }
    
    private func genericPathPoints() -> [CGPoint] {
        var begin: CGPoint
        var control: CGPoint
        let end = CGPoint.middle(p1: points[step], p2: points[step + 1])

        var vertices: [CGPoint] = []
        if step == 1 {
            begin = points[0]
            let middle1 = CGPoint.middle(p1: points[0], p2: points[1])
            control = CGPoint.middle(p1: middle1, p2: points[1])
        } else {
            begin = CGPoint.middle(p1: points[step - 1], p2: points[step])
            control = points[step]
        }
        
        /// segements are based on distance about start and end point
        let dis = begin.distance(to: end)
        let segements = max(Int(dis / 5), 2)

        for i in 0 ..< segements {
            let t = CGFloat(i) / CGFloat(segements)
            let x = pow(1 - t, 2) * begin.x + 2.0 * (1 - t) * t * control.x + t * t * end.x
            let y = pow(1 - t, 2) * begin.y + 2.0 * (1 - t) * t * control.y + t * t * end.y
            vertices.append(CGPoint(x: x, y: y))
        }
        vertices.append(end)
        return vertices
    }
}
