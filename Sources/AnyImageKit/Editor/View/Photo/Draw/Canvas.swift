//
//  Canvas.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/24.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

final class Canvas: DryDrawingView {
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private lazy var lineWidth = options.brush.lineWidth.width
    private lazy var brush = Brush(color: options.brush.colors[options.brush.defaultColorIndex].color, lineWidth: options.brush.lineWidth.width)
    private var currentShapeLayer: CAShapeLayer? = nil
    private var shapeLayers: [CAShapeLayer] = []

    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        bindViewModel()
        clipsToBounds = true
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willBeginDraw(path: DryDrawingBezierPath) {
        viewModel.send(action: .brushBeginDraw)
        brush.lineWidth = lineWidth / viewModel.scrollView!.zoomScale
        let shapeLayer = getShapeLayer(with: path, brush: brush)
        layer.addSublayer(shapeLayer)
        shapeLayers.append(shapeLayer)
        currentShapeLayer = shapeLayer
    }
    
    override func panning(path: DryDrawingBezierPath) {
        currentShapeLayer?.path = path.cgPath
    }
    
    override func didFinishDraw(path: DryDrawingBezierPath) {
        currentShapeLayer?.path = path.cgPath
        currentShapeLayer = nil
        let scale = (viewModel.imageSize.width / frame.width) * viewModel.scrollView!.zoomScale
        let drawnPath = DrawnPath(brush: brush, scale: scale, points: path.points)
        viewModel.send(action: .brushFinishDraw(BrushData(drawnPath: drawnPath)))
    }
}

// MARK: - Observer
extension Canvas {
    
    private func bindViewModel() {
        viewModel.actionSubject.sink { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .toolOptionChanged(let option):
                self.isUserInteractionEnabled = option == .brush
            case .brushChangeColor(let color):
                self.brush.color = color
            case .brushChangeLineWidth(let width):
                self.lineWidth = width
            case .brushUndo:
                if self.shapeLayers.isEmpty { return }
                let shapeLayer = self.shapeLayers.removeLast()
                shapeLayer.removeFromSuperlayer()
            default:
                break
            }
        }.store(in: &cancellable)
    }
}

// MARK: - Public
extension Canvas {
    
    func updateView(with edit: PhotoEditingStack.Edit, force: Bool = false) {
        let drawnPaths = edit.brushData.map { $0.drawnPath }
        currentShapeLayer = nil
        shapeLayers.forEach { $0.removeFromSuperlayer() }
        shapeLayers.removeAll()
        for drawnPath in drawnPaths {
            let scale = frame.size.width / viewModel.imageSize.width
            let path = drawnPath.brushedPath(scale: scale)
            let shapeLayer = getShapeLayer(with: path, brush: drawnPath.brush.scale(scale))
            layer.addSublayer(shapeLayer)
            shapeLayers.append(shapeLayer)
        }
    }
}

// MARK: - Private
extension Canvas {
    
    private func getShapeLayer(with path: DryDrawingBezierPath, brush: Brush) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = brush.color.cgColor
        shapeLayer.lineWidth = brush.lineWidth
        return shapeLayer
    }
}
