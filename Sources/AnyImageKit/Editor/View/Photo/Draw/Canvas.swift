//
//  Canvas.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/24.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol CanvasDelegate: AnyObject {
    
    func canvasDidBeginDraw()
    func canvasDidEndDraw()
}

protocol CanvasDataSource: AnyObject {
    
    func canvasGetLineWidth(_ canvas: Canvas) -> CGFloat
}

final class Canvas: DryDrawingView {

    weak var delegate: CanvasDelegate?
    weak var dataSource: CanvasDataSource?
    
    var didDraw: (() -> Void)?
    
    private(set) var brush = Brush()
    private(set) var drawnPaths: [DrawnPath] = []

    override func willBeginDraw(path: UIBezierPath) {
        delegate?.canvasDidBeginDraw()
        brush.lineWidth = dataSource?.canvasGetLineWidth(self) ?? 5.0
        let drawnPath = DrawnPath(brush: brush, scale: scale, path: path)
        drawnPaths.append(drawnPath)
        setNeedsDisplay()
    }
    
    override func panning(path: UIBezierPath) {
        setNeedsDisplay()
    }
    
    override func didFinishDraw(path: UIBezierPath) {
        delegate?.canvasDidEndDraw()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        drawnPaths.forEach { $0.draw(in: ctx, size: bounds.size, scale: scale) }
        didDraw?()
    }
}

// MARK: - Public
extension Canvas {
    
    func setBrush(lineWidth: CGFloat) {
        brush.lineWidth = lineWidth
    }
    
    func setBrush(color: UIColor) {
        brush.color = color
    }
    
    func updateView(with edit: PhotoEditingStack.Edit) {
        let newDrawnPaths = edit.brushData.map { $0.drawnPath }
        guard drawnPaths != newDrawnPaths else { return }
        drawnPaths = newDrawnPaths
        setNeedsDisplay()
    }
}
