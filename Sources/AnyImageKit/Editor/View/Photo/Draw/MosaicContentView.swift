//
//  MosaicContentView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/25.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class MosaicContentView: DryDrawingView {

    weak var dataSource: MosaicDataSource?
    weak var delegate: MosaicDelegate?
    
    var didDraw: (() -> Void)? {
        didSet {
            maskLayer.didDraw = didDraw
        }
    }
    
    let idx: Int
    
    private(set) var brush = Brush()
    private(set) var drawnPaths: [DrawnPath] = [] {
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
        layer.scale = { [weak self] in
            return self?.scale ?? 1.0
        }
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
    
    override func willBeginDraw(path: UIBezierPath) {
        delegate?.mosaicDidBeginDraw()
        brush.lineWidth = dataSource?.mosaicGetLineWidth() ?? 15.0
        let drawnPath = DrawnPath(brush: brush, scale: scale, path: path)
        drawnPaths.append(drawnPath)
    }
    
    override func panning(path: UIBezierPath) {
        updateMask()
    }
    
    override func didFinishDraw(path: UIBezierPath) {
        delegate?.mosaicDidEndDraw()
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
    
    func updateMask() {
        maskLayer.drawnPaths = drawnPaths
    }
}

// MARK: - Public
extension MosaicContentView {
    
    func setDrawn(paths: [DrawnPath]) {
        drawnPaths = paths
    }
}

// MARK: - MaskLayer
private class MaskLayer: CALayer {
    
    var didDraw: (() -> Void)?
    var scale: (() -> CGFloat)?
    
    var drawnPaths: [DrawnPath] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(in ctx: CGContext) {
        drawnPaths.forEach { $0.draw(in: ctx, size: bounds.size, scale: scale?() ?? 1.0) }
        didDraw?()
    }
}
