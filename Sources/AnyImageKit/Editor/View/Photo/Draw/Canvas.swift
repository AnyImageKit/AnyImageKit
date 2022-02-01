//
//  Canvas.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/11/24.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Combine

protocol CanvasDelegate: AnyObject {
    
    func canvasDidBeginDraw()
    func canvasDidEndDraw()
}

final class Canvas: DryDrawingView {

    weak var delegate: CanvasDelegate?
    
    private var options: EditorPhotoOptionsInfo { viewModel.options }
    private let viewModel: PhotoEditorViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private lazy var lineWidth = options.brush.lineWidth.width
    private lazy var brush = Brush(color: options.brush.colors[options.brush.defaultColorIndex].color, lineWidth: options.brush.lineWidth.width)
    private(set) var drawnPaths: [DrawnPath] = []
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
        print("Create layer ", #function)
    }
    
    override func panning(path: DryDrawingBezierPath) {
        currentShapeLayer?.path = path.cgPath
        print("layer == \(currentShapeLayer != nil) ", #function)
    }
    
    override func didFinishDraw(path: DryDrawingBezierPath) {
        currentShapeLayer?.path = path.cgPath
        currentShapeLayer = nil
        print("layer = nil ", #function)
        let scale = (viewModel.imageSize.width / frame.width) * viewModel.scrollView!.zoomScale
        let drawnPath = DrawnPath(brush: brush, scale: scale, points: path.points)
        drawnPaths.append(drawnPath)
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
        let newDrawnPaths = edit.brushData.map { $0.drawnPath }
        guard force || drawnPaths != newDrawnPaths else { return }
        drawnPaths = newDrawnPaths
        
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
        shapeLayer.path = path.cgPath
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.strokeColor = brush.color.cgColor
        shapeLayer.lineWidth = brush.lineWidth
        return shapeLayer
    }
}
