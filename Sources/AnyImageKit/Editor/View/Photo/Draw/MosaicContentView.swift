//
//  MosaicContentView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/25.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class MosaicContentView: DryDrawingView {

    let idx: Int
    let uuid: String
    let mosaic: UIImage
    var lineWidth: CGFloat = 5.0
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    
    private var brush = Brush()
    
    /// Used to draw mosaic view
    private(set) var drawnPaths: [DrawnPath] = [] {
        didSet {
            updateMask()
        }
    }
    
    private lazy var contentLayer: CALayer = {
        let contentLayer = CALayer()
        contentLayer.mask = maskLayer
        return contentLayer
    }()
    
    private lazy var maskLayer: MaskLayer = {
        let layer = MaskLayer()
        layer.scale = { [weak self] in
            guard let self = self else { return 1.0 }
            return self.frame.size.width / self.viewModel.imageSize.width
        }
        layer.contentsScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        return layer
    }()
    
    private var pathBeforeBegin = DryDrawingBezierPath()
    
    init(viewModel: PhotoEditorViewModel, idx: Int, mosaic: UIImage, lineWidth: CGFloat, uuid: String) {
        self.idx = idx
        self.mosaic = mosaic
        self.lineWidth = lineWidth
        self.uuid = uuid
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willBeginDraw(path: DryDrawingBezierPath) {
        viewModel.send(action: .mosaicBeginDraw)
        brush.lineWidth = lineWidth / viewModel.scrollView!.zoomScale
        let drawnPath = DrawnPath(brush: brush, scale: 1.0, points: path.points)
        drawnPaths.append(drawnPath)
        setNeedsDisplay()
    }
    
    override func panning(path: DryDrawingBezierPath) {
        guard !drawnPaths.isEmpty else { return }
        let drawnPath = DrawnPath(brush: brush, scale: 1.0, points: path.points)
        drawnPaths[drawnPaths.count-1] = drawnPath
        updateMask()
    }
    
    override func didFinishDraw(path: DryDrawingBezierPath) {
        guard !drawnPaths.isEmpty else { return }
        let drawnPath = DrawnPath(brush: brush, scale: 1.0, points: path.points)
        drawnPaths[drawnPaths.count-1] = drawnPath
        updateMask()
        
        let scale = (viewModel.imageSize.width / frame.width) * viewModel.scrollView!.zoomScale
        let stackDrawnPaths = drawnPaths.map {
            DrawnPath(brush: $0.brush, scale: scale, points: $0.points)
        }
        viewModel.send(action: .mosaicFinishDraw(MosaicData(idx: idx, drawnPaths: stackDrawnPaths, uuid: uuid)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if maskLayer.frame == .zero {
            updateLayerFrame()
        }
    }
}

// MARK: - Public
extension MosaicContentView {
    
    func undo() {
        drawnPaths.removeLast()
    }
    
    func setDrawn(paths: [DrawnPath], scale: CGFloat) {
        drawnPaths = paths.map {
            DrawnPath(brush: $0.brush, scale: scale, points: $0.points)
        }
    }
    
    func updateMask() {
        maskLayer.drawnPaths = drawnPaths
    }
    
    func updateLayerFrame() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        contentLayer.frame = bounds
        maskLayer.frame = bounds
        CATransaction.commit()
    }
}

// MARK: - UI
extension MosaicContentView {
    
    private func setupView() {
        layer.addSublayer(contentLayer)
        contentLayer.contents = mosaic.cgImage
        brush.lineWidth = lineWidth / viewModel.scrollView!.zoomScale
    }
}

// MARK: - MaskLayer
private class MaskLayer: CALayer {
    
    var scale: (() -> CGFloat)?
    
    var drawnPaths: [DrawnPath] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(in ctx: CGContext) {
        drawnPaths.forEach { $0.draw(in: ctx, size: bounds.size, scale: scale?() ?? 1.0) }
    }
}
