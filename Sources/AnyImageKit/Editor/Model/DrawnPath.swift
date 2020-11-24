//
//  DrawnPath.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/9.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

struct DrawnPath : GraphicsDrawing, Equatable {
    
    public let brush: Brush
    public let bezierPath: UIBezierPath
    
    public init(brush: Brush, path: UIBezierPath) {
        self.brush = brush
        self.bezierPath = path
    }
    
    public func draw(in context: CGContext, canvasSize: CGSize) {
        UIGraphicsPushContext(context)
        context.saveGState()
        defer {
            context.restoreGState()
            UIGraphicsPopContext()
        }
        draw()
    }
    
    private func draw() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        defer {
            context.restoreGState()
        }
        
        brush.color.setStroke()
        let bezierPath = brushedPath()
        bezierPath.stroke()
    }
    
    private func brushedPath() -> UIBezierPath {
        let _bezierPath = bezierPath.copy() as! UIBezierPath
        _bezierPath.lineJoinStyle = .round
        _bezierPath.lineCapStyle = .round
        _bezierPath.lineWidth = brush.lineWidth
        return _bezierPath
    }
}
