//
//  PhotoEditorContentView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

final class PhotoEditorContentView: UIView {
    
    private(set) lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.clipsToBounds = false
        view.delegate = self
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(image: image)
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    /// 画板 - pen
    private(set) lazy var canvas: Canvas = {
        let view = Canvas(frame: .zero)
        view.delegate = self
        view.dataSource = self
        view.isUserInteractionEnabled = false
        view.setBrush(lineWidth: options.penWidth)
        return view
    }()
    /// 马赛克，延时加载
    internal var mosaic: Mosaic?
    /// 裁剪 - Crop
    /// 裁剪框的四个角
    private let cornerFrame = CGRect(x: 0, y: 0, width: 40, height: 40)
    private(set) lazy var topLeftCorner: CropCornerView = {
        let view = CropCornerView(frame: cornerFrame, color: .white, position: .topLeft)
        view.alpha = 0
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panCropCorner(_:))))
        return view
    }()
    private(set) lazy var topRightCorner: CropCornerView = {
        let view = CropCornerView(frame: cornerFrame, color: .white, position: .topRight)
        view.alpha = 0
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panCropCorner(_:))))
        return view
    }()
    private(set) lazy var bottomLeftCorner: CropCornerView = {
        let view = CropCornerView(frame: cornerFrame, color: .white, position: .bottomLeft)
        view.alpha = 0
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panCropCorner(_:))))
        return view
    }()
    private(set) lazy var bottomRightCorner: CropCornerView = {
        let view = CropCornerView(frame: cornerFrame, color: .white, position: .bottomRight)
        view.alpha = 0
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panCropCorner(_:))))
        return view
    }()
    /// 裁剪框的矩形
    private(set) lazy var gridView: CropGridView = {
        let view = CropGridView(frame: UIScreen.main.bounds)
        view.alpha = 0
        return view
    }()
    /// 用于裁剪后把其他区域以黑色layer盖住
    private(set) lazy var cropLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = bounds
        layer.fillRule = .evenOdd
        layer.fillColor = UIColor.black.cgColor
        return layer
    }()
    /// 文本视图
    internal var textImageViews: [TextImageView] = []
    
    /// 原始图片
    internal let image: UIImage
    /// Context
    internal let context: PhotoEditorContext
    /// 配置项
    internal var options: EditorPhotoOptionsInfo {
        return context.options
    }
    /// 裁剪数据
    internal var cropContext: PhotoEditorCropContext = .init()
    
    init(frame: CGRect, image: UIImage, context: PhotoEditorContext) {
        self.image = image
        self.context = context
        super.init(frame: frame)
        backgroundColor = .black
        setupView()
        layout()
        
        if cropContext.cropRealRect == .zero {
            cropContext.cropRealRect = imageView.frame
        }
        updateCanvasFrame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        imageView.addSubview(canvas)
        setupCropView()
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSingleTapped)))
    }
    
    internal func layout() {
        scrollView.frame = bounds
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.contentInset = .zero
        imageView.frame = fitFrame
        scrollView.contentSize = imageView.bounds.size
    }
    
    internal func animate(withDuration duration: TimeInterval, animations: @escaping () -> Void) {
        if duration <= 0 {
            animations()
        } else {
            UIView.animate(withDuration: duration, animations: animations)
        }
    }
    
    internal func updateView(with edit: PhotoEditingStack.Edit) {
        guard edit.isEdited else { return }
        updateCanvasFrame()
        canvas.updateView(with: edit)
        mosaic?.updateView(with: edit)
        updateTextView(with: edit)
        cropContext.lastCropData = edit.cropData
        
        let group = DispatchGroup()
        if !edit.penData.isEmpty {
            group.enter()
            canvas.didDraw = { [weak self] in
                self?.canvas.didDraw = nil
                group.leave()
            }
        }
        if !edit.mosaicData.isEmpty {
            group.enter()
            mosaic?.didDraw = { [weak self] in
                self?.mosaic?.didDraw = nil
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.layoutEndCrop(edit.isEdited)
            self?.updateCanvasFrame()
        }
    }
}

// MARK: - Target
extension PhotoEditorContentView {
    
    @objc private func onSingleTapped() {
        context.action(.empty)
    }
}

// MARK: - UIScrollViewDelegate
extension PhotoEditorContentView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if !cropContext.isCrop && !cropContext.didCrop {
            imageView.center = centerOfContentSize
        }
    }
}
