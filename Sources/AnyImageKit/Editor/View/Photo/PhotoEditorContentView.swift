//
//  PhotoEditorContentView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
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
        view.isUserInteractionEnabled = true
        return view
    }()
    private(set) lazy var mirrorCropView: MirrorCropView = {
        let view = MirrorCropView(frame: .zero)
        view.isHidden = true
        view.alpha = 0.8
        view.color = .black
        return view
    }()
    /// 画板 - Brush
    private(set) lazy var canvas: Canvas = {
        let view = Canvas(frame: .zero)
        view.delegate = self
        view.dataSource = self
        view.isUserInteractionEnabled = false
        view.setBrush(lineWidth: options.brushWidth)
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
        return view
    }()
    /// 用于裁剪后把其他区域以黑色layer盖住
    private(set) lazy var cropLayerLeave: CropLayerView = {
        let view = CropLayerView(frame: bounds)
        return view
    }()
    /// 用于裁剪前进入裁剪时的动画切换时的蒙版
    /// 不用 `cropLayerLeave` 的原因是切换 path 时会产生不可控的动画
    private(set) lazy var cropLayerEnter: CropLayerView = {
        let view = CropLayerView(frame: bounds)
        return view
    }()
    /// 文本视图
    internal var textImageViews: [TextImageView] = []
    /// 文本删除视图
    private(set) lazy var textTrashView: TextTrashView = {
        let view = TextTrashView(options: options, frame: CGRect(x: (bounds.width - 160) / 2, y: bounds.height, width: 160, height: 80))
        view.alpha = 0
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
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
        updateSubviewFrame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupCropLayer()
    }
    
    private func setupView() {
        addSubview(scrollView)
        addSubview(textTrashView)
        scrollView.addSubview(imageView)
        imageView.addSubview(mirrorCropView)
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
    
    internal func updateSubviewFrame() {
        mirrorCropView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        canvas.frame = CGRect(origin: .zero, size: imageView.bounds.size)
        mosaic?.frame = CGRect(origin: .zero, size: imageView.bounds.size)
        mosaic?.layoutSubviews()
    }
    
    internal func updateView(with edit: PhotoEditingStack.Edit, completion: (() -> Void)? = nil) {
        updateSubviewFrame()
        canvas.updateView(with: edit)
        mosaic?.updateView(with: edit)
        updateTextView(with: edit)
        
        let group = DispatchGroup()
        if !edit.brushData.isEmpty {
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
            guard let self = self else { completion?(); return }
            if edit.cropData.didCropOrRotate && self.cropContext.lastCropData != edit.cropData {
                self.cropContext.lastCropData = edit.cropData
                self.layoutEndCrop(edit.isEdited)
                self.updateSubviewFrame()
            }
            completion?()
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
        guard !cropContext.isCrop else { return }
        if !cropContext.didCrop {
            imageView.center = centerOfContentSize
        } else {
            let scale = scrollView.zoomScale / cropContext.lastCropData.zoomScale
            let contentSize = cropContext.contentSize.multipliedBy(scale)
            let imageFrame = cropContext.imageViewFrame.multipliedBy(scale)
            
            let leftOffset = cropContext.croppedSize.width * scale
            let deltaWidth = scrollView.bounds.width - contentSize.width
            let offsetX = (deltaWidth > 0 ? deltaWidth / 2 : 0) - leftOffset
            let centerX = imageFrame.width / 2 + offsetX
            
            let topOffset = cropContext.croppedSize.height * scale
            let deltaHeight = scrollView.bounds.height - contentSize.height
            let offsetY = (deltaHeight > 0 ? deltaHeight / 2 : 0) - topOffset
            let centerY = imageFrame.height / 2 + offsetY
            
            imageView.center = CGPoint(x: centerX, y: centerY)
            scrollView.contentSize = contentSize
        }
    }
}
