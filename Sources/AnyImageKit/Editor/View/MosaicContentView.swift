//
//  MosaicContentView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/25.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

final class MosaicContentView: DryDrawingView {

    weak var dataSource: MosaicDataSource?
    weak var delegate: MosaicDelegate?
    
    let idx: Int
    
    var brush = Brush()
    var drawnPaths: [DrawnPath] = [] {
        didSet {
            updateMask()
        }
    }
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.mask = maskLayer
        return view
    }()
    private lazy var maskLayer: MaskLayer = {
        let layer = MaskLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        return layer
    }()
    
    init(idx: Int, mosaic: UIImage) {
        self.idx = idx
        super.init(frame: .zero)
        addSubview(imageView)
        imageView.image = mosaic
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willBeginPan(path: UIBezierPath) {
        delegate?.mosaicDidBeginPen()
        brush.lineWidth = dataSource?.mosaicGetLineWidth() ?? 15.0
        let drawnPath = DrawnPath(brush: brush, path: path)
        drawnPaths.append(drawnPath)
    }
    
    override func panning(path: UIBezierPath) {
        updateMask()
    }
    
    override func didFinishPan(path: UIBezierPath) {
        delegate?.mosaicDidEndPen()
        updateMask()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        maskLayer.frame = bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    private func updateMask() {
        maskLayer.drawnPaths = drawnPaths
    }
}

// MARK: - Public
extension MosaicContentView {
    
    public func undo() -> Bool {
        guard !drawnPaths.isEmpty else { return false }
        drawnPaths.removeLast()
        return true
    }
}

// MARK: - MaskLayer
private class MaskLayer: CALayer {
    
    var drawnPaths: [GraphicsDrawing] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(in ctx: CGContext) {
        drawnPaths.forEach { $0.draw(in: ctx, canvasSize: bounds.size) }
    }
}
