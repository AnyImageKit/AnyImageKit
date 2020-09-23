//
//  BezierGenerator.swift
//  AnyImageKit
//
//  Created by Harley.xk on 2017/11/10.
//
//  The BezierGenerator is a modified version of
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

final class BezierGenerator {
    
    var points: [CGPoint] = []
    private var step = 0
    
    init() { }
    
    init(beginPoint: CGPoint) {
        begin(with: beginPoint)
    }
}

// MARK: - Public function
extension BezierGenerator {
    
    func begin(with point: CGPoint) {
        step = 0
        points.removeAll()
        points.append(point)
    }
    
    func pushPoint(_ point: CGPoint) -> [CGPoint] {
        if point == points.last {
            return []
        }
        points.append(point)
        if points.count < 3 {
            return []
        }
        step += 1
        let result = genericPathPoints()
        return result
    }
    
    func finish() {
        step = 0
        points.removeAll()
    }
    
}

extension BezierGenerator {
    
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
