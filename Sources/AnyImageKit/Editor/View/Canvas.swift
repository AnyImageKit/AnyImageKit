//
//  Canvas.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/24.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol CanvasDelegate: AnyObject {
    
    func canvasDidBeginPen()
    func canvasDidEndPen()
}

protocol CanvasDataSource: AnyObject {
    
    func canvasGetLineWidth(_ canvas: Canvas) -> CGFloat
}

final class Canvas: DryDrawingView {

    weak var delegate: CanvasDelegate?
    weak var dataSource: CanvasDataSource?
    
    var brush = Brush()
    var drawnPaths: [DrawnPath] = []

    override func willBeginPan(path: UIBezierPath) {
        delegate?.canvasDidBeginPen()
        brush.lineWidth = dataSource?.canvasGetLineWidth(self) ?? 5.0
        let drawnPath = DrawnPath(brush: brush, path: path)
        drawnPaths.append(drawnPath)
        setNeedsDisplay()
    }
    
    override func panning(path: UIBezierPath) {
        setNeedsDisplay()
    }
    
    override func didFinishPan(path: UIBezierPath) {
        delegate?.canvasDidEndPen()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        drawnPaths.forEach { $0.draw(in: ctx, canvasSize: bounds.size) }
    }
}

// MARK: - Public
extension Canvas {
    
    public func undo() {
        guard !drawnPaths.isEmpty else { return }
        drawnPaths.removeLast()
        layer.setNeedsDisplay()
    }
}
