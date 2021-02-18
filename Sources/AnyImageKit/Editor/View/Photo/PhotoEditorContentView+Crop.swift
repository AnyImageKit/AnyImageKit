//
//  PhotoEditorContentView+Crop.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

// MARK: - Public function
extension PhotoEditorContentView {

    /// 设置裁剪尺寸
    func setCrop(_ option: EditorCropOption) {
        cropOption = option
        let rect = getCropRect(by: option)
        if rect != .zero {
            UIView.animate(withDuration: 0.5) {
                self.layoutStartCrop(animated: false, setCrop: false)
                self.setCropRect(rect, animated: true)
                self.updateScrollViewAndCropRect(nil)
            }
        }
    }
    
    /// 开始裁剪
    func cropStart(with option: EditorCropOption? = nil) {
        isCrop = true
        lastImageViewBounds = imageView.bounds
        cropLayerEnter.frame = cropLayerLeave.frame
        UIView.animate(withDuration: 0.25, animations: {
            if !self.didCrop {
                self.layoutStartCrop()
            } else {
                self.layoutStartCroped()
            }
            self.updateSubviewFrame()
        }, completion: { _ in
            self.gridView.bgLayer.opacity = 1.0
            self.cropLayerEnter.removeFromSuperview()
            self.setCropHidden(false, animated: true)
            if let cropOption = option {
                self.setCrop(cropOption)
            }
        })
    }
    
    /// 取消裁剪
    func cropCancel(completion: ((Bool) -> Void)? = nil) {
        isCrop = false
        setCropHidden(true, animated: false)
        if didCrop {
            scrollView.zoomScale = lastCropData.zoomScale
            scrollView.contentSize = lastCropData.contentSize
            imageView.frame = lastCropData.imageViewFrame
            scrollView.contentOffset = lastCropData.contentOffset
            setCropRect(lastCropData.rect, animated: true)
        }
        UIView.animate(withDuration: 0.25, animations: {
            if self.didCrop {
                self.layoutEndCrop()
            } else {
                self.layout()
            }
            self.updateSubviewFrame()
        }, completion: completion)
    }
    
    /// 裁剪完成
    func cropDone(completion: ((Bool) -> Void)? = nil) {
        isCrop = false
        didCrop = cropRect.size != scrollView.contentSize
        setCropHidden(true, animated: false)
        layoutEndCrop()
        UIView.animate(withDuration: 0.25, animations: {
            self.updateSubviewFrame()
        }, completion: completion)
    }
    
    /// 重置裁剪
    func cropReset() {
        UIView.animate(withDuration: 0.5, animations: {
            self.layoutStartCrop(animated: true)
            self.updateSubviewFrame()
        })
    }
}

// MARK: - Target
extension PhotoEditorContentView {
    
    /// 白色裁剪框4个角的pan手势
    @objc func panCropCorner(_ gr: UIPanGestureRecognizer) {
        guard let cornerView = gr.view as? CropCornerView else { return }
        let position = cornerView.position
        let point = gr.translation(in: self)
        gr.setTranslation(.zero, in: self)
        
        if gr.state == .began {
            cropStartPanRect = cropRect
        }
        
        if cropOption == .free {
            updateCropRect(point, position)
        } else {
            updateCropRectWithCropOption(point, position)
        }
        
        if gr.state == .ended {
            updateScrollViewAndCropRect(position)
        }
    }
}

// MARK: - Private function
extension PhotoEditorContentView {
    
    /// 设置裁剪相关控件
    internal func setupCropView() {
        addSubview(gridView)
        addSubview(topLeftCorner)
        addSubview(topRightCorner)
        addSubview(bottomLeftCorner)
        addSubview(bottomRightCorner)
    }
    
    /// 布局开始裁剪 - 未裁剪过
    private func layoutStartCrop(animated: Bool = false, setCrop: Bool = true) {
        let top = cropY
        let bottom = cropBottomOffset
        scrollView.frame = CGRect(x: cropX, y: top, width: bounds.width-cropX*2, height: bounds.height-top-bottom)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.zoomScale = 1.0
        
        let cropFrame = self.cropFrame
        imageView.frame = cropFrame
        imageView.frame.origin.x -= cropX
        imageView.frame.origin.y -= top
        scrollView.contentSize = imageView.bounds.size
        
        if setCrop {
            setCropRect(cropFrame, animated: animated)
        }
        
        setupContentInset()
    }
    
    /// 布局开始裁剪 - 已裁剪过
    private func layoutStartCroped() {
        let oldImageViewFrame = imageView.frame
        let top = cropY
        let bottom = cropBottomOffset
        scrollView.frame = CGRect(x: cropX, y: top, width: bounds.width-cropX*2, height: bounds.height-top-bottom)
        scrollView.maximumZoomScale = maximumZoomScale
  
        // 加载上次裁剪数据
        scrollView.zoomScale = lastCropData.zoomScale
        scrollView.contentSize = lastCropData.contentSize
        imageView.frame = lastCropData.imageViewFrame
        scrollView.contentOffset = lastCropData.contentOffset
        setCropRect(lastCropData.rect, animated: true)
        
        // minimumZoomScale
        let isVertical = cropRect.height * (scrollView.bounds.width / cropRect.width) > scrollView.bounds.height
        let mZoom1 = scrollView.bounds.width / imageView.bounds.width
        let mZoom2 = scrollView.bounds.height / imageView.bounds.height
        let mZoom: CGFloat
        if !isVertical {
            mZoom = (imageView.bounds.height < cropRect.height) ? (cropRect.height / imageView.bounds.height) : mZoom1
        } else {
            mZoom = (imageView.bounds.width < cropRect.width) ? (cropRect.width / imageView.bounds.width) : mZoom2
        }
        scrollView.minimumZoomScale = mZoom
        
        setupContentInset()
        
        // CropLayer
        let cropOffsetX = UIScreen.main.bounds.width
        let cropOffsetY = UIScreen.main.bounds.height
        let scale = lastCropData.zoomScale
        let rectPathRect = CGRect(origin: CGPoint(x: (cropRealRect.minX - oldImageViewFrame.minX) / scale + cropOffsetX,
                                                  y: (cropRealRect.minY - oldImageViewFrame.minY) / scale + cropOffsetY),
                                  size: CGSize(width: cropRealRect.width / scale,
                                               height: cropRealRect.height / scale))
        let cropPath = UIBezierPath(rect: cropLayerEnter.frame)
        let rectPath = UIBezierPath(rect: rectPathRect)
        cropPath.append(rectPath)
        cropLayerEnter.path = cropPath.cgPath
        imageView.addSubview(cropLayerEnter)
        cropLayerLeave.removeFromSuperview()
        
        let newRectPathRect = CGRect(origin: CGPoint(x: lastCropData.contentOffset.x / scale + cropOffsetX,
                                                     y: lastCropData.contentOffset.y / scale + cropOffsetY),
                                     size: CGSize(width: lastCropData.rect.width / scale,
                                                  height: lastCropData.rect.height / scale))
        let newCropPath = UIBezierPath(rect: cropLayerEnter.frame)
        let newRectPath = UIBezierPath(rect: newRectPathRect)
        newCropPath.append(newRectPath)
        let cropAnimation = CABasicAnimation.create(duration: 0.25, fromValue: cropLayerEnter.path, toValue: newCropPath.cgPath)
        cropLayerEnter.cropLayer.add(cropAnimation, forKey: "path")
        cropLayerEnter.path = newCropPath.cgPath
    }
    
    /// 布局裁剪结束
    func layoutEndCrop(_ fromCache: Bool = false) {
        if fromCache {
            let top = cropY
            let bottom = cropBottomOffset
            scrollView.frame = CGRect(x: cropX, y: top, width: bounds.width-cropX*2, height: bounds.height-top-bottom)
            scrollView.zoomScale = lastCropData.zoomScale
            scrollView.contentSize = lastCropData.contentSize
            imageView.frame = lastCropData.imageViewFrame
            scrollView.contentOffset = lastCropData.contentOffset
            setCropRect(lastCropData.rect)
            didCrop = cropRect.size != scrollView.contentSize
        } else {
            lastCropData.didCrop = didCrop
            lastCropData.rect = cropRect
            lastCropData.zoomScale = scrollView.zoomScale
            lastCropData.contentSize = scrollView.contentSize
            lastCropData.contentOffset = scrollView.contentOffset
            lastCropData.imageViewFrame = imageView.frame
            context.action(.cropFinish(lastCropData))
        }
        
        let scale = scrollView.zoomScale
        var contentSize: CGSize = .zero
        contentSize.width = bounds.width
        contentSize.height = bounds.width * cropRect.height / cropRect.width
        
        var imageSize: CGSize = .zero
        imageSize.width = contentSize.width * imageView.frame.width / cropRect.width
        imageSize.height = contentSize.height * imageView.frame.height / cropRect.height
        
        let contentOffset = scrollView.contentOffset
        let offsetX = contentOffset.x * imageSize.width / imageView.frame.width
        let offsetY = contentOffset.y * imageSize.height / imageView.frame.height
        let x = (bounds.width - contentSize.width) > 0 ? (bounds.width - contentSize.width) * 0.5 : 0
        let y = (bounds.height - contentSize.height) > 0 ? (bounds.height - contentSize.height) * 0.5 : 0
        
        // Set
        scrollView.minimumZoomScale = didCrop ? scale : 1.0
        cropRealRect = CGRect(origin: CGPoint(x: x, y: y), size: contentSize)
        cropContext.contentSize = contentSize
        UIView.animate(withDuration: fromCache ? 0 : 0.25) {
            self.scrollView.frame = self.bounds
            self.scrollView.contentInset = .zero
            
            self.imageView.frame.origin = CGPoint(x: x - offsetX, y: y - offsetY)
            self.imageView.frame.size = imageSize
            self.scrollView.contentSize = contentSize
            self.cropContext.imageViewFrame = self.imageView.frame
            self.cropContext.croppedHeight = self.cropRealRect.minY - self.imageView.frame.minY
        }
        
        // CropLayer
        guard didCrop else { return }
        cropLayerLeave.frame = imageView.bounds
        let cropOffsetX = UIScreen.main.bounds.width
        let cropOffsetY = UIScreen.main.bounds.height
        cropLayerLeave.frame.origin.x -= cropOffsetX
        cropLayerLeave.frame.origin.y -= cropOffsetY
        cropLayerLeave.frame.size.width += cropOffsetX * 4
        cropLayerLeave.frame.size.height += cropOffsetY * 4
        imageView.addSubview(cropLayerLeave)
        
        let rectPathRect = CGRect(origin: CGPoint(x: contentOffset.x / scale + cropOffsetX,
                                                  y: contentOffset.y / scale + cropOffsetY),
                                  size: CGSize(width: cropRect.width / scale,
                                               height: cropRect.height / scale))
        let cropPath = UIBezierPath(rect: cropLayerLeave.frame)
        let rectPath = UIBezierPath(rect: rectPathRect)
        cropPath.append(rectPath)
        cropLayerLeave.path = cropPath.cgPath
        
        // 因为要使 TextView 超出 Image 隐藏起来，所以四周增加一段蒙版
        let newRectPathRect = CGRect(origin: CGPoint(x: (cropRealRect.minX - imageView.frame.minX) / scale + cropOffsetX,
                                                     y: (cropRealRect.minY - imageView.frame.minY) / scale + cropOffsetY),
                                     size: CGSize(width: cropRealRect.width / scale,
                                                  height: cropRealRect.height / scale))
        let newCropPath = UIBezierPath(rect: cropLayerLeave.frame)
        let newRectPath = UIBezierPath(rect: newRectPathRect)
        newCropPath.append(newRectPath)
        if !fromCache {
            let cropAnimation = CABasicAnimation.create(duration: 0.25, fromValue: cropLayerLeave.path, toValue: newCropPath.cgPath)
            cropLayerLeave.cropLayer.add(cropAnimation, forKey: "path")
        }
        cropLayerLeave.displayRect = newRectPathRect
        cropLayerLeave.path = newCropPath.cgPath
    }
    
    /// 设置无裁剪状态时的遮罩
    func setupCropLayer() {
        guard !didCrop && cropLayerLeave.superview == nil else { return }
        cropLayerLeave.frame = imageView.bounds
        let cropOffsetX = UIScreen.main.bounds.width
        let cropOffsetY = UIScreen.main.bounds.height
        cropLayerLeave.frame.origin.x -= cropOffsetX
        cropLayerLeave.frame.origin.y -= cropOffsetY
        cropLayerLeave.frame.size.width += cropOffsetX * 4
        cropLayerLeave.frame.size.height += cropOffsetY * 4
        imageView.addSubview(cropLayerLeave)
        
        let rectPathRect = CGRect(origin: CGPoint(x: cropOffsetX, y: cropOffsetY),
                                  size: scrollView.contentSize)
        let cropPath = UIBezierPath(rect: cropLayerLeave.frame)
        let rectPath = UIBezierPath(rect: rectPathRect)
        cropPath.append(rectPath)
        cropLayerLeave.displayRect = rectPathRect
        cropLayerLeave.path = cropPath.cgPath
    }
    
    /// 设置白色裁剪框的frame
    private func setCropRect(_ rect: CGRect, animated: Bool = false) {
        cropRect = rect
        let origin = rect.origin
        let size = rect.size
        topLeftCorner.center = origin
        topRightCorner.center = CGPoint(x: origin.x + size.width, y: origin.y)
        bottomLeftCorner.center = CGPoint(x: origin.x, y: origin.y + size.height)
        bottomRightCorner.center = CGPoint(x: origin.x + size.width, y: origin.y + size.height)
        gridView.setRect(rect, animated: animated)
    }
    
    /// 显示/隐藏白色裁剪框
    private func setCropHidden(_ hidden: Bool, animated: Bool) {
        gridView.setHidden(hidden, animated: animated)
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.topLeftCorner.alpha = hidden ? 0 : 1
            self.topRightCorner.alpha = hidden ? 0 : 1
            self.bottomLeftCorner.alpha = hidden ? 0 : 1
            self.bottomRightCorner.alpha = hidden ? 0 : 1
        }
    }
    
    /// 设置contentInset
    private func setupContentInset() {
        let rightInset = scrollView.bounds.width - cropRect.width + 0.1
        let bottomInset = scrollView.bounds.height - cropRect.height + 0.1
        scrollView.contentInset = UIEdgeInsets(top: 0.1, left: 0.1, bottom: bottomInset, right: rightInset)
    }
}

// MARK: - Calculate
extension PhotoEditorContentView {
    
    /// pan手势移动中，计算新的裁剪框的位置
    private func updateCropRect(_ point: CGPoint, _ position: CropCornerPosition) {
        let limit: CGFloat = 55
        var rect = cropRect
        let isXUp = rect.size.width - point.x > limit && rect.origin.x + point.x > imageView.frame.origin.x + scrollView.frame.origin.x - scrollView.contentOffset.x
        let isXDown = rect.size.width + point.x > limit && rect.size.width + point.x < imageView.frame.size.width - scrollView.contentOffset.x
        let isYUp = rect.size.height - point.y > limit && rect.origin.y + point.y > imageView.frame.origin.y + scrollView.frame.origin.y - scrollView.contentOffset.y
        let isYDown = rect.size.height + point.y > limit && rect.size.height + point.y < imageView.frame.size.height - scrollView.contentOffset.y
        switch position {
        case .topLeft: // x+ y+
            if isXUp {
                rect.origin.x += point.x
                rect.size.width -= point.x
            }
            if isYUp  {
                rect.origin.y += point.y
                rect.size.height -= point.y
            }
        case .topRight: // x- y+
            if isXDown {
                rect.size.width += point.x
            }
            if isYUp {
                rect.origin.y += point.y
                rect.size.height -= point.y
            }
        case .bottomLeft: // x+ y-
            if isXUp {
                rect.origin.x += point.x
                rect.size.width -= point.x
            }
            if isYDown {
                rect.size.height += point.y
            }
        case .bottomRight: // x- y-
            if isXDown {
                rect.size.width += point.x
            }
            if isYDown {
                rect.size.height += point.y
            }
        }
        setCropRect(rect)
    }
    
    /// pan手势移动中，计算新的裁剪框的位置，用设置了裁剪比例的情况下
    private func updateCropRectWithCropOption(_ point: CGPoint, _ posision: CropCornerPosition) {
        let limit: CGFloat = 55
        var rect = cropRect
        let ratio: CGPoint
        if point.x != 0 {
            ratio = CGPoint(x: point.x, y: point.x / cropOption.ratioOfWidth)
        } else if point.y != 0 {
            ratio = CGPoint(x: point.y / cropOption.ratioOfHeight, y: point.y)
        } else {
            ratio = point
        }
        switch posision {
        case .topLeft: // x+ y+
            if point.x != 0 {
                rect.origin.x += point.x
                rect.origin.y += ratio.y
                rect.size.width -= point.x
                rect.size.height -= ratio.y
            } else if point.y != 0 {
                rect.origin.x += ratio.x
                rect.origin.y += point.y
                rect.size.width -= ratio.x
                rect.size.height -= point.y
            }
        case .topRight: // x- y+
            if point.x != 0 {
                rect.origin.y -= ratio.y
                rect.size.width += point.x
                rect.size.height += ratio.y
            } else if point.y != 0 {
                rect.origin.y += point.y
                rect.size.width -= ratio.x
                rect.size.height -= point.y
            }
        case .bottomLeft: // x+ y-
            if point.x != 0 {
                rect.origin.x += point.x
                rect.size.width -= point.x
                rect.size.height -= ratio.y
            } else if point.y != 0 {
                rect.origin.x -= ratio.x
                rect.size.width += ratio.x
                rect.size.height += point.y
            }
        case .bottomRight: // x- y-
            if point.x != 0 {
                rect.size.width += point.x
                rect.size.height += ratio.y
            } else if point.y != 0 {
                rect.size.width += ratio.x
                rect.size.height += point.y
            }
        }
        if rect.width < limit || rect.height < limit
            || rect.origin.x < imageView.frame.origin.x + scrollView.frame.origin.x - scrollView.contentOffset.x
            || rect.origin.y < imageView.frame.origin.y + scrollView.frame.origin.y - scrollView.contentOffset.y
            || rect.width > imageView.frame.width - scrollView.contentOffset.x
            || rect.height > imageView.frame.height - scrollView.contentOffset.y {
            return
        }
        setCropRect(rect)
    }
    
    /// pan手势移动结束，根据裁剪框位置，计算scrollView的zoomScale、minimumZoomScale、contentOffset，以及新的裁剪框的位置
    private func updateScrollViewAndCropRect(_ position: CropCornerPosition?) {
        // zoomScale
        let maxZoom = scrollView.maximumZoomScale
        let zoomH = scrollView.bounds.width / (cropRect.width / scrollView.zoomScale)
        let zoomV = scrollView.bounds.height / (cropRect.height / scrollView.zoomScale)
        let isVertical = cropRect.height * (scrollView.bounds.width / cropRect.width) > scrollView.bounds.height
        let zoom: CGFloat
        if !isVertical {
            zoom = zoomH > maxZoom ? maxZoom : zoomH
        } else {
            zoom = zoomV > maxZoom ? maxZoom : zoomV
        }
        
        // contentOffset
        let zoomScale = zoom / scrollView.zoomScale
        let offset: CGPoint
        if let position = position {
            let offsetX = (scrollView.contentOffset.x * zoomScale) + ((cropRect.origin.x - cropStartPanRect.origin.x) * zoomScale)
            let offsetY = (scrollView.contentOffset.y * zoomScale) + ((cropRect.origin.y - cropStartPanRect.origin.y) * zoomScale)
            switch position {
            case .topLeft:
                offset = CGPoint(x: offsetX, y: offsetY)
            case .topRight:
                offset = CGPoint(x: scrollView.contentOffset.x * zoomScale, y: offsetY)
            case .bottomLeft:
                offset = CGPoint(x: offsetX, y: scrollView.contentOffset.y * zoomScale)
            case .bottomRight:
                offset = CGPoint(x: scrollView.contentOffset.x * zoomScale, y: scrollView.contentOffset.y * zoomScale)
            }
        } else { // 设置裁剪尺寸分支
            let offsetX = (scrollView.contentSize.width - cropRect.width) / 2 * zoomScale
            let offsetY = (scrollView.contentSize.height - cropRect.height) / 2 * zoomScale
            offset = CGPoint(x: offsetX, y: offsetY)
        }
        
        // newCropRect
        let newCropRect: CGRect
        if (zoom == maxZoom && !isVertical) || zoom == zoomH {
            let scale = scrollView.bounds.width / cropRect.width
            let height = cropRect.height * scale
            let y = (scrollView.bounds.height - height) / 2 + scrollView.frame.origin.y
            newCropRect = CGRect(x: scrollView.frame.origin.x, y: y, width: scrollView.bounds.width, height: height)
        } else {
            let scale = scrollView.bounds.height / cropRect.height
            let width = cropRect.width * scale
            let x = (scrollView.bounds.width - width) / 2 + scrollView.frame.origin.x
            newCropRect = CGRect(x: x, y: scrollView.frame.origin.y, width: width, height: scrollView.frame.height)
        }
        
        // minimumZoomScale
        let mZoomH = scrollView.bounds.width / imageView.bounds.width
        let mZoomV = scrollView.bounds.height / imageView.bounds.height
        let mZoom: CGFloat
        if !isVertical {
            mZoom = (imageView.bounds.height < newCropRect.height) ? (newCropRect.height / imageView.bounds.height) : mZoomH
        } else {
            mZoom = (imageView.bounds.width < newCropRect.width) ? (newCropRect.width / imageView.bounds.width) : mZoomV
        }
        
        // set
        UIView.animate(withDuration: 0.5, animations: {
            self.setCropRect(newCropRect, animated: true)
            self.imageView.frame.origin.x = newCropRect.origin.x - self.scrollView.frame.origin.x
            self.imageView.frame.origin.y = newCropRect.origin.y - self.scrollView.frame.origin.y
            self.scrollView.zoomScale = zoom
            self.scrollView.contentOffset = offset
        })
        
        // set
        setupContentInset()
        scrollView.minimumZoomScale = mZoom
    }
    
    // 根据裁剪比例计算实际裁剪大小
    private func getCropRect(by option: EditorCropOption) -> CGRect {
        switch option {
        case .free:
            return .zero
        case .custom(let w, let h):
            let w = CGFloat(w), h = CGFloat(h)
            let cropFrame = self.cropFrame
            var newCrop: CGRect = .zero
            if w / h >= cropFrame.width / cropFrame.height {
                newCrop.size.width = cropFrame.width
                newCrop.size.height = newCrop.width * h / w
            } else {
                newCrop.size.height = cropFrame.height
                newCrop.size.width = newCrop.height * w / h
            }
            newCrop.origin.x = (cropFrame.width - newCrop.width) / 2 + cropFrame.origin.x
            newCrop.origin.y = (cropFrame.height - newCrop.height) / 2 + cropFrame.origin.y
            return newCrop
        }
    }
}

// MARK: - Getter & Setter
extension PhotoEditorContentView {
    
    /// 正在裁剪
    fileprivate var isCrop: Bool {
        get { return cropContext.isCrop }
        set { cropContext.isCrop = newValue }
    }
    /// 图片已经裁剪
    fileprivate var didCrop: Bool {
        get { return cropContext.didCrop }
        set { cropContext.didCrop = newValue }
    }
    /// 裁剪框的位置
    fileprivate var cropRect: CGRect {
        get { return cropContext.cropRect }
        set { cropContext.cropRect = newValue }
    }
    /// pan手势开始时裁剪框的位置
    fileprivate var cropStartPanRect: CGRect {
        get { return cropContext.cropStartPanRect }
        set { cropContext.cropStartPanRect = newValue }
    }
    /// 裁剪框与imageView真实的位置
    fileprivate var cropRealRect: CGRect {
        get { return cropContext.cropRealRect }
        set { cropContext.cropRealRect = newValue }
    }
    /// 裁剪尺寸
    fileprivate var cropOption: EditorCropOption {
        get { return cropContext.cropOption }
        set { cropContext.cropOption = newValue }
    }
    /// 上次裁剪开始时图片的Bounds
    fileprivate var lastImageViewBounds: CGRect {
        get { return cropContext.lastImageViewBounds }
        set { cropContext.lastImageViewBounds = newValue }
    }
    /// 上次裁剪的数据，用于再次进入裁剪
    fileprivate var lastCropData: CropData {
        get { return cropContext.lastCropData }
        set { cropContext.lastCropData = newValue }
    }
}
