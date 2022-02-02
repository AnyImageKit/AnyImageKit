//
//  MosaicContentView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/25.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class MosaicContentView: DryDrawingView {

    let idx: Int
    let uuid: String
    let mosaic: UIImage
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private var brush = Brush()
    private lazy var lineWidth = options.mosaic.lineWidth.width
    
    /// Used to draw mosaic view
    private(set) var drawnPaths: [DrawnPath] = []
    
    private lazy var contentLayer: CALayer = {
        let contentLayer = CALayer()
        contentLayer.mask = maskLayer
        return contentLayer
    }()
    
    private lazy var maskLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.white.cgColor
        return shapeLayer
    }()
    
    private var pathBeforeBegin = DryDrawingBezierPath()
    
    init(viewModel: PhotoEditorViewModel, idx: Int, mosaic: UIImage, uuid: String) {
        self.idx = idx
        self.uuid = uuid
        self.mosaic = mosaic
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willBeginDraw(path: DryDrawingBezierPath) {
        viewModel.send(action: .mosaicBeginDraw)
        brush.lineWidth = lineWidth / viewModel.scrollView!.zoomScale
        maskLayer.lineWidth = brush.lineWidth
        
        if let cgPath = maskLayer.path {
            pathBeforeBegin = DryDrawingBezierPath(cgPath: cgPath)
            let newPath = DryDrawingBezierPath(cgPath: cgPath)
            newPath.append(path)
            maskLayer.path = newPath.cgPath
        } else {
            pathBeforeBegin = path
            maskLayer.path = path.cgPath
        }
    }
    
    override func panning(path: DryDrawingBezierPath) {
        let newPath = DryDrawingBezierPath(cgPath: pathBeforeBegin.cgPath)
        newPath.append(path)
        maskLayer.path = newPath.cgPath
    }
    
    override func didFinishDraw(path: DryDrawingBezierPath) {
        let newPath = DryDrawingBezierPath(cgPath: pathBeforeBegin.cgPath)
        newPath.append(path)
        maskLayer.path = newPath.cgPath
        
        let scale = (viewModel.imageSize.width / frame.width) * viewModel.scrollView!.zoomScale
        drawnPaths.append(DrawnPath(brush: brush, scale: scale, points: path.points))
        viewModel.send(action: .mosaicFinishDraw(MosaicData(idx: idx, drawnPaths: drawnPaths, uuid: uuid)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        contentLayer.frame = bounds
        maskLayer.frame = bounds
        CATransaction.commit()
    }
}

// MARK: - Observer
extension MosaicContentView {
    
    private func bindViewModel() {
        viewModel.actionSubject.sink { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .mosaicChangeLineWidth(let width):
                self.lineWidth = width
            default:
                break
            }
        }.store(in: &cancellable)
    }
}

// MARK: - Public
extension MosaicContentView {
    
    func undo() {
        drawnPaths.removeLast()
    }
    
    func setDrawn(paths: [DrawnPath], scale: CGFloat) {
        drawnPaths = paths
        
        maskLayer.path = nil
        for drawnPath in drawnPaths {
            maskLayer.lineWidth = drawnPath.brush.lineWidth * scale
            let path = drawnPath.brushedPath(scale: scale)
            
            if let cgPath = maskLayer.path {
                let newPath = DryDrawingBezierPath(cgPath: cgPath)
                newPath.append(path)
                maskLayer.path = newPath.cgPath
            } else {
                maskLayer.path = path.cgPath
            }
        }
    }
}

// MARK: - UI
extension MosaicContentView {
    
    private func setupView() {
        layer.addSublayer(contentLayer)
        contentLayer.contents = mosaic.cgImage
        
        brush.lineWidth = lineWidth / viewModel.scrollView!.zoomScale
        maskLayer.lineWidth = brush.lineWidth
    }
}
