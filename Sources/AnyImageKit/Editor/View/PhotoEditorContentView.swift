//
//  PhotoEditorContentView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol PhotoEditorContentViewDelegate: AnyObject {
    
    func contentViewTapped()
    
    func photoDidBeginPen()
    func photoDidEndPen()
    
    func mosaicDidCreated()
    
    func inputTextWillBeginEdit(_ data: TextData)
}

final class PhotoEditorContentView: UIView {

    weak var delegate: PhotoEditorContentViewDelegate?
    
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
        view.brush.lineWidth = options.penWidth
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
    
    /// 原始图片
    internal let image: UIImage
    /// 配置项
    internal let options: EditorPhotoOptionsInfo
    
    /// 正在裁剪
    internal var isCrop: Bool = false
    /// 图片已经裁剪
    internal var didCrop: Bool = false
    /// 裁剪框的位置
    internal var cropRect: CGRect = .zero
    /// pan手势开始时裁剪框的位置
    internal var cropStartPanRect: CGRect = .zero
    /// 裁剪框与imageView真实的位置
    internal var cropRealRect: CGRect = .zero
    /// 上次裁剪的数据，用于再次进入裁剪
    internal var lastCropData: CropData = CropData()
    /// 裁剪前的图片
    internal var imageBeforeCrop: UIImage?
    /// 裁剪尺寸
    internal var cropOption: EditorCropOption = .free
    
    /// 存储画笔过程的图片
    internal lazy var penCache = CacheTool(config: CacheConfig(module: .editor(.pen), useDiskCache: true, autoRemoveDiskCache: options.cacheIdentifier.isEmpty))
    /// 存储马赛克过程图片
    internal lazy var mosaicCache = CacheTool(config: CacheConfig(module: .editor(.mosaic), useDiskCache: true, autoRemoveDiskCache: options.cacheIdentifier.isEmpty))
    
    internal var textImageViews: [TextImageView] = []
    internal var lastImageViewBounds: CGRect = .zero
    
    /// 是否编辑
    internal var isEdited: Bool {
        return didCrop || penCache.hasDiskCache() || mosaicCache.hasDiskCache() || !textImageViews.isEmpty
    }
    
    init(frame: CGRect, image: UIImage, options: EditorPhotoOptionsInfo, cache: ImageEditorCache?) {
        self.image = image
        self.options = options
        super.init(frame: frame)
        backgroundColor = .black
        setupView()
        setupMosaicView()
        
        layout()
        setup(from: cache)
        if cropRealRect == .zero {
            cropRealRect = imageView.frame
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
    
    private func setup(from cache: ImageEditorCache?) {
        guard let cache = cache else { return }
        lastCropData = cache.cropData
        penCache = CacheTool(config: CacheConfig(module: .editor(.pen), useDiskCache: true, autoRemoveDiskCache: options.cacheIdentifier.isEmpty), diskCacheList: cache.penCacheList)
        mosaicCache = CacheTool(config: CacheConfig(module: .editor(.mosaic), useDiskCache: true, autoRemoveDiskCache: options.cacheIdentifier.isEmpty), diskCacheList: cache.mosaicCacheList)
        imageView.image = mosaicCache.read(deleteMemoryStorage: false) ?? image
        canvas.lastPenImageView.image = penCache.read(deleteMemoryStorage: false)
        cache.textDataList.forEach {
            addText(data: $0)
        }
        layoutEndCrop(true)
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
}

// MARK: - Target
extension PhotoEditorContentView {
    
    @objc private func onSingleTapped() {
        delegate?.contentViewTapped()
    }
}

// MARK: - UIScrollViewDelegate
extension PhotoEditorContentView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if !isCrop && !didCrop {
            imageView.center = centerOfContentSize
        }
    }
}
