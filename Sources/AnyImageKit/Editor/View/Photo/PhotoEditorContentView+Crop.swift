//
//  PhotoEditorContentView+Crop.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
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
        lastScrollViewBounds = scrollView.bounds
        lastImageViewBounds = imageView.bounds
        cropLayerEnter.frame = cropLayerLeave.frame
        UIView.animate(withDuration: 0.25, animations: {
            if !self.cropOrRotate {
                self.layoutStartCrop()
            } else {
                self.layoutStartCroped()
            }
            self.updateSubviewFrame()
        }, completion: { _ in
            self.gridView.bgLayer.opacity = 1.0
            self.cropLayerEnter.removeFromSuperview()
            self.cropLayerLeave.removeFromSuperview()
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
        // 基础设置
        if cropOrRotate {
            scrollView.zoomScale = lastCropData.zoomScale
            scrollView.contentSize = lastCropData.contentSize
            imageView.frame = lastCropData.imageViewFrame
            scrollView.contentOffset = lastCropData.contentOffset
            setCropRect(lastCropData.rect, animated: true)
        }
        UIView.animate(withDuration: 0.25, animations: {
            // 旋转设置
            if self.rotateState != self.lastCropData.rotateState {
                self.rotateState = self.lastCropData.rotateState
                self.scrollView.transform = CGAffineTransform(rotationAngle: self.rotateState.angle)
                self.scrollView.bounds = self.lastScrollViewBounds
            }
            
            if self.cropOrRotate {
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
        didCrop = cropRect.size.roundTo(places: 1) != (scrollView.contentSize.reversed(!rotateState.isPortrait).roundTo(places: 1))
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
    
    /// 旋转
    func rotate() {
        setMirrorCropRect(cropRect)
        rotateState = RotateState.nextState(of: rotateState, direction: options.rotationDirection)
        layoutRotation()
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
        
        var imageFrame = CGRect(origin: .zero, size: cropSize.reversed(!rotateState.isPortrait))
        if self.rotateState.isPortrait {
            imageFrame.origin.x = cropFrame.origin.x - scrollView.frame.origin.x
            imageFrame.origin.y = cropFrame.origin.y - scrollView.frame.origin.y
        } else {
            imageFrame.origin.x = (scrollView.bounds.width - cropFrame.height) / 2
            imageFrame.origin.y = (scrollView.bounds.height - cropFrame.width) / 2
        }
        imageView.frame = imageFrame

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
  
        // 加载上次裁剪数据
        scrollView.zoomScale = lastCropData.zoomScale
        scrollView.contentSize = lastCropData.contentSize
        imageView.frame = lastCropData.imageViewFrame
        scrollView.contentOffset = lastCropData.contentOffset
        setCropRect(lastCropData.rect, animated: true)
        
        // minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.minimumZoomScale = getMinimumZoomScale(with: lastCropData.rect.size, imageSize: lastCropData.imageViewFrame.size)
        
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
        
        let lastCropSize = lastCropData.rect.size.reversed(!rotateState.isPortrait)
        let newRectPathRect = CGRect(origin: CGPoint(x: lastCropData.contentOffset.x / scale + cropOffsetX,
                                                     y: lastCropData.contentOffset.y / scale + cropOffsetY),
                                     size: CGSize(width: lastCropSize.width / scale,
                                                  height: lastCropSize.height / scale))
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
            rotateState = lastCropData.rotateState
            scrollView.transform = CGAffineTransform(rotationAngle: rotateState.angle)
            scrollView.bounds = CGRect(origin: .zero, size: scrollView.bounds.size.reversed(!rotateState.isPortrait))
            
            let top = cropY
            let bottom = cropBottomOffset
            scrollView.frame = CGRect(x: cropX, y: top, width: bounds.width-cropX*2, height: bounds.height-top-bottom)
            scrollView.zoomScale = lastCropData.zoomScale
            scrollView.contentSize = lastCropData.contentSize
            imageView.frame = lastCropData.imageViewFrame
            scrollView.contentOffset = lastCropData.contentOffset
            setCropRect(lastCropData.rect)
            didCrop = cropRect.size.roundTo(places: 1) != (scrollView.contentSize.reversed(!rotateState.isPortrait).roundTo(places: 1))
            
            scrollView.maximumZoomScale = maximumZoomScale
            scrollView.minimumZoomScale = getMinimumZoomScale(with: lastCropData.rect.size, imageSize: lastCropData.imageViewFrame.size)
        } else {
            lastCropData.didCrop = didCrop
            lastCropData.rect = cropRect
            lastCropData.zoomScale = scrollView.zoomScale
            lastCropData.contentSize = scrollView.contentSize
            lastCropData.contentOffset = scrollView.contentOffset
            lastCropData.imageViewFrame = imageView.frame
            lastCropData.rotateState = rotateState
            context.action(.cropFinish(lastCropData))
        }
        
        let scale = scrollView.zoomScale
        let isPortrait = rotateState.isPortrait
        let boundsSize = bounds.size.reversed(!isPortrait)
        let reversedCropRect = cropRect.size.reversed(!isPortrait)
        let imageFrameSize = imageView.frame.size
        let contentSize = CGSize(width: bounds.width, height: bounds.width * cropRect.height / cropRect.width).reversed(!isPortrait)
        let imageSize = CGSize(width: contentSize.width * imageFrameSize.width / reversedCropRect.width,
                               height: contentSize.height * imageFrameSize.height / reversedCropRect.height)

        let contentOffset = scrollView.contentOffset
        let offsetX = contentOffset.x * imageSize.width / imageFrameSize.width
        let offsetY = contentOffset.y * imageSize.height / imageFrameSize.height
        let x = (boundsSize.width - contentSize.width) > 0 ? (boundsSize.width - contentSize.width) * 0.5 : 0
        let y = (boundsSize.height - contentSize.height) > 0 ? (boundsSize.height - contentSize.height) * 0.5 : 0
        
        // Set
        scrollView.minimumZoomScale = cropOrRotate ? scale : 1.0
        cropRealRect = CGRect(origin: CGPoint(x: x, y: y), size: contentSize)
        cropContext.contentSize = contentSize
        UIView.animate(withDuration: fromCache ? 0 : 0.25) {
            self.scrollView.frame = self.bounds
            self.scrollView.contentInset = .zero
            
            self.imageView.frame.origin = CGPoint(x: x - offsetX, y: y - offsetY)
            self.imageView.frame.size = imageSize
            self.scrollView.contentSize = contentSize
            self.cropContext.imageViewFrame = self.imageView.frame
            self.cropContext.croppedSize = CGSize(width: self.cropRealRect.minX - self.imageView.frame.minX,
                                                  height: self.cropRealRect.minY - self.imageView.frame.minY)
        }
        
        // CropLayer
        guard cropOrRotate else { return }
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
                                  size: CGSize(width: reversedCropRect.width / scale,
                                               height: reversedCropRect.height / scale))
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
    
    /// 旋转
    private func layoutRotation() {
        setCropHidden(true, animated: false, inRotation: true)
        mirrorCropView.isHidden = false

        let scrollViewCenter = self.scrollView.center
        let contentOffset = self.scrollView.contentOffset
        let imageViewFrame = self.imageView.frame
        
        let newCropRect: CGRect = {
            let r = cropRect
            var rect: CGRect = .zero
            let scaleX = cropMaxSize.width / r.size.height
            let scaleY = cropMaxSize.height / r.size.width
            let scale = min(scaleX, scaleY)
            rect.size.width = r.size.height * scale
            rect.size.height = r.size.width * scale
            rect.origin.x = scrollViewCenter.x - rect.size.width / 2.0
            rect.origin.y = scrollViewCenter.y - rect.size.height / 2.0
            return rect
        }()
        
        UIView.animate(withDuration: 0.25) {
            self.scrollView.transform = CGAffineTransform(rotationAngle: self.rotateState.angle)
            self.scrollView.bounds = CGRect(origin: .zero, size: self.scrollView.bounds.size.reversed())
            
            // Image frame
            var newImageFrame: CGRect = .zero
            newImageFrame.size.width = imageViewFrame.width / self.cropRect.width * newCropRect.height
            newImageFrame.size.height = imageViewFrame.height / self.cropRect.height * newCropRect.width
            if self.rotateState.isPortrait {
                newImageFrame.origin.x = newCropRect.origin.x - self.scrollView.frame.origin.x
                newImageFrame.origin.y = newCropRect.origin.y - self.scrollView.frame.origin.y
            } else {
                newImageFrame.origin.x = (self.scrollView.bounds.width - newCropRect.height) / 2
                newImageFrame.origin.y = (self.scrollView.bounds.height - newCropRect.width) / 2
            }
            
            // Zoom Scale
            let newZoomScale = newImageFrame.width / newCropRect.width
            if newZoomScale > self.scrollView.maximumZoomScale {
                self.scrollView.maximumZoomScale = newZoomScale
            }
            if newZoomScale < self.scrollView.minimumZoomScale {
                self.scrollView.minimumZoomScale = newZoomScale
            }
            self.scrollView.zoomScale = newZoomScale
            
            // Content Offset
            var newContentOffset: CGPoint = .zero
            newContentOffset.x = contentOffset.x / imageViewFrame.width * newImageFrame.width
            newContentOffset.y = contentOffset.y / imageViewFrame.height * newImageFrame.height

            // Set
            self.imageView.frame = newImageFrame
            self.scrollView.center = scrollViewCenter
            self.scrollView.contentSize = newImageFrame.size
            self.scrollView.contentOffset = newContentOffset
            self.scrollView.minimumZoomScale = self.getMinimumZoomScale(with: newCropRect.size, imageSize: newImageFrame.size)
            self.scrollView.maximumZoomScale = self.maximumZoomScale
            self.setMirrorCropRect(newCropRect, animated: true)
        } completion: { _ in
            self.setCropRect(newCropRect, animated: false)
            self.setCropHidden(false, animated: true, inRotation: true)
            self.mirrorCropView.isHidden = true
            self.setupContentInset()
            
            if case let .custom(w, h) = self.cropOption {
                self.cropOption = .custom(w: h, h: w)
            }
        }
    }
    
    /// 设置无裁剪状态时的遮罩
    internal func setupCropLayer() {
        guard !cropOrRotate && !cropContext.isCrop && cropLayerLeave.superview == nil else { return }
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
    
    /// 设置 imageView 中的蒙版，用于旋转时保持周围有黑色蒙层
    private func setMirrorCropRect(_ rect: CGRect, animated: Bool = false) {
        let rectSize = rect.size.reversed(!rotateState.isPortrait)
        let rectPathRect = CGRect(origin: scrollView.contentOffset.multipliedBy(1/scrollView.zoomScale),
                                  size: CGSize(width: rectSize.width / imageView.frame.width * imageView.bounds.width,
                                               height: rectSize.height / imageView.frame.height * imageView.bounds.height))
        mirrorCropView.setRect(rectPathRect)
        layoutIfNeeded()
    }
    
    /// 显示/隐藏白色裁剪框
    private func setCropHidden(_ hidden: Bool, animated: Bool, inRotation: Bool = false) {
        if inRotation {
            gridView.alpha = hidden ? 0 : 1
        } else {
            gridView.setHidden(hidden, animated: animated)
        }
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.topLeftCorner.alpha = hidden ? 0 : 1
            self.topRightCorner.alpha = hidden ? 0 : 1
            self.bottomLeftCorner.alpha = hidden ? 0 : 1
            self.bottomRightCorner.alpha = hidden ? 0 : 1
        }
    }
    
    /// 设置contentInset
    private func setupContentInset() {
        if rotateState.isPortrait {
            let rightInset = scrollView.bounds.width - cropRect.width + 0.1
            let bottomInset = scrollView.bounds.height - cropRect.height + 0.1
            scrollView.contentInset = UIEdgeInsets(top: 0.1, left: 0.1, bottom: bottomInset, right: rightInset)
        } else {
            let rightInset = scrollView.bounds.width - cropRect.height + 0.1
            let bottomInset = scrollView.bounds.height - cropRect.width + 0.1
            scrollView.contentInset = UIEdgeInsets(top: 0.1, left: 0.1, bottom: bottomInset, right: rightInset)
        }
    }
}

// MARK: - Calculate
extension PhotoEditorContentView {
    
    /// 计算最小缩放比例
    private func getMinimumZoomScale(with cropSize: CGSize, imageSize: CGSize) -> CGFloat {
        let maxSize = cropMaxSize
        let imageSize = imageSize.reversed(!rotateState.isPortrait)
        let imageOriginSize = imageView.bounds.size.reversed(!rotateState.isPortrait)
        let isHorizontal = cropSize.height * (maxSize.width / cropSize.width) <  maxSize.height
         
        if isHorizontal {
            let imageFitSize = CGSize(width: cropSize.width, height: imageSize.height / imageSize.width * cropSize.width)
            return imageFitSize.height < cropSize.height ? (cropSize.height / imageOriginSize.height) : (cropSize.width / imageOriginSize.width)
        } else {
            let imageFitSize = CGSize(width: imageSize.width / imageSize.height * cropSize.height, height: cropSize.height)
            return imageFitSize.width < cropSize.width ? (cropSize.width / imageOriginSize.width) : (cropSize.height / imageOriginSize.height)
        }
    }
    
    /// pan手势移动中，计算新的裁剪框的位置
    private func updateCropRect(_ point: CGPoint, _ position: CropCornerPosition) {
        let limit: CGFloat = 55
        var rect = cropRect
        
        let isXUp: Bool
        let isXDown: Bool
        let isYUp: Bool
        let isYDown: Bool
        let imageFrame = imageView.frame
        let contentOffset = scrollView.contentOffset
        
        // 第一个条件控制最小边界；第二个条件控制最大边界
        if rotateState.isPortrait {
            let offsetX = rotateState == .portrait ? contentOffset.x : imageFrame.width - cropStartPanRect.width - contentOffset.x
            let offsetY = rotateState == .portrait ? contentOffset.y : imageFrame.height - cropStartPanRect.height - contentOffset.y
            
            isXUp = rect.width - point.x > limit && rect.minX + point.x > imageFrame.minX + scrollView.frame.minX - offsetX
            isYUp = rect.height - point.y > limit && rect.minY + point.y > imageFrame.minY + scrollView.frame.minY - offsetY
            isXDown = rect.width + point.x > limit && rect.width + point.x < imageFrame.width - offsetX
            isYDown = rect.height + point.y > limit && rect.height + point.y < imageFrame.height - offsetY
        } else {
            let offsetX = rotateState == .landscapeLeft ? contentOffset.y : imageFrame.height - cropStartPanRect.width - contentOffset.y
            let offsetYUp = rotateState == .landscapeLeft ? contentOffset.x : imageFrame.width - cropStartPanRect.height - contentOffset.x
            let offsetYDown = rotateState == .landscapeLeft ? imageFrame.width - cropStartPanRect.height - contentOffset.x : contentOffset.x
            
            isXUp = rect.width - point.x > limit && rect.minX + point.x > imageFrame.minY + scrollView.frame.minX - offsetX
            isYUp = rect.height - point.y > limit && rect.height - point.y < imageFrame.width - offsetYUp
            isXDown = rect.width + point.x > limit && rect.width + point.x < imageFrame.height - offsetX
            isYDown = rect.height + point.y > limit && rect.height + point.y < imageFrame.width - offsetYDown
        }
        
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
    private func updateCropRectWithCropOption(_ point: CGPoint, _ position: CropCornerPosition) {
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
        switch position {
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
        
        let isXUp: Bool
        let isXDown: Bool
        let isYUp: Bool
        let isYDown: Bool
        let imageFrame = imageView.frame
        let contentOffset = scrollView.contentOffset
        
        // 第一个条件控制最小边界；第二个条件控制最大边界
        if rotateState.isPortrait {
            let offsetX = rotateState != .upsideDown ? contentOffset.x : imageFrame.width - cropStartPanRect.width - contentOffset.x
            let offsetY = rotateState != .upsideDown ? contentOffset.y : imageFrame.height - cropStartPanRect.height - contentOffset.y
            
            isXUp = rect.width < limit || rect.minX < imageFrame.minX + scrollView.frame.minX - offsetX
            isYUp = rect.height < limit || rect.minY < imageFrame.minY + scrollView.frame.minY - offsetY
            isXDown = rect.width < limit || rect.width > imageFrame.width - offsetX
            isYDown = rect.height < limit || rect.height > imageFrame.height - offsetY
        } else {
            let offsetX = rotateState == .landscapeLeft ? contentOffset.y : imageFrame.height - cropStartPanRect.width - contentOffset.y
            let offsetYUp = rotateState == .landscapeLeft ? contentOffset.x : imageFrame.width - cropStartPanRect.height - contentOffset.x
            let offsetYDown = rotateState == .landscapeLeft ? imageFrame.width - cropStartPanRect.height - contentOffset.x : contentOffset.x
            
            isXUp = rect.width < limit || rect.minX < imageFrame.minY + scrollView.frame.minX - offsetX
            isYUp = rect.height < limit || rect.height > imageFrame.width - offsetYUp
            isXDown = rect.width < limit || rect.width > imageFrame.height - offsetX
            isYDown = rect.height < limit || rect.height > imageFrame.width - offsetYDown
        }
        
        switch position {
        case .topLeft: // x+ y+
            if isXUp || isYUp {
                return
            }
        case .topRight: // x- y+
            if isXDown || isYUp {
                return
            }
        case .bottomLeft: // x+ y-
            if isXUp || isYDown {
                return
            }
        case .bottomRight: // x- y-
            if isXDown || isYDown {
                return
            }
        }
        setCropRect(rect)
    }
    
    /// pan手势移动结束，根据裁剪框位置，计算scrollView的zoomScale、minimumZoomScale、contentOffset，以及新的裁剪框的位置
    private func updateScrollViewAndCropRect(_ position: CropCornerPosition?) {
        // zoomScale
        let maxZoom = scrollView.maximumZoomScale
        let contentOffset = scrollView.contentOffset
        let scrollViewBounds = scrollView.bounds.size.reversed(!rotateState.isPortrait)
        
        let zoom: CGFloat
        let zoomH = scrollViewBounds.width / (cropRect.width / scrollView.zoomScale)
        let zoomV = scrollViewBounds.height / (cropRect.height / scrollView.zoomScale)
        let isVertical = cropRect.height * (scrollViewBounds.width / cropRect.width) > scrollViewBounds.height
        if !isVertical {
            zoom = zoomH > maxZoom ? maxZoom : zoomH
        } else {
            zoom = zoomV > maxZoom ? maxZoom : zoomV
        }
        
        // contentOffset
        let zoomScale = zoom / scrollView.zoomScale
        let offset: CGPoint
        if let _position = position {
            let position = RotateState.getCropCornerPosition(by: rotateState, position: _position)
            let offsetX: CGFloat
            let offsetY: CGFloat
            if rotateState.isPortrait {
                offsetX = (contentOffset.x * zoomScale) + ((cropStartPanRect.width - cropRect.width) * zoomScale)
                offsetY = (contentOffset.y * zoomScale) + ((cropStartPanRect.height - cropRect.height) * zoomScale)
            } else {
                offsetX = (contentOffset.x * zoomScale) + ((cropStartPanRect.height - cropRect.height) * zoomScale)
                offsetY = (contentOffset.y * zoomScale) + ((cropStartPanRect.width - cropRect.width) * zoomScale)
            }
            
            switch position {
            case .topLeft:
                offset = CGPoint(x: offsetX, y: offsetY)
            case .topRight:
                offset = CGPoint(x: contentOffset.x * zoomScale, y: offsetY)
            case .bottomLeft:
                offset = CGPoint(x: offsetX, y: contentOffset.y * zoomScale)
            case .bottomRight:
                offset = CGPoint(x: contentOffset.x * zoomScale, y: contentOffset.y * zoomScale)
            }
        } else { // 设置指定裁剪尺寸分支
            let cropSize = cropRect.size.reversed(!rotateState.isPortrait)
            let offsetX = (scrollView.contentSize.width - cropSize.width) / 2 * zoomScale
            let offsetY = (scrollView.contentSize.height - cropSize.height) / 2 * zoomScale
            offset = CGPoint(x: offsetX, y: offsetY)
        }
        
        // New CropRect
        let newCropRect: CGRect
        if (zoom == maxZoom && !isVertical) || zoom == zoomH { // 横向
            let scale = scrollViewBounds.width / cropRect.width
            let height = cropRect.height * scale
            let y = (scrollViewBounds.height - height) / 2 + scrollView.frame.origin.y
            newCropRect = CGRect(x: scrollView.frame.origin.x, y: y, width: scrollViewBounds.width, height: height)
        } else { // 竖向
            let scale = scrollViewBounds.height / cropRect.height
            let width = cropRect.width * scale
            let x = (scrollViewBounds.width - width) / 2 + scrollView.frame.origin.x
            newCropRect = CGRect(x: x, y: scrollView.frame.origin.y, width: width, height: scrollViewBounds.height)
        }
        
        // set
        UIView.animate(withDuration: 0.5, animations: {
            self.setCropRect(newCropRect, animated: true)
            
            var newImageFrame = self.imageView.frame
            if self.rotateState.isPortrait {
                newImageFrame.origin.x = newCropRect.origin.x - self.scrollView.frame.origin.x
                newImageFrame.origin.y = newCropRect.origin.y - self.scrollView.frame.origin.y
            } else {
                newImageFrame.origin.y = newCropRect.origin.x - self.scrollView.frame.origin.x
                newImageFrame.origin.x = newCropRect.origin.y - self.scrollView.frame.origin.y
            }
            newImageFrame.size = newImageFrame.size.multipliedBy(zoomScale)
            
            self.scrollView.zoomScale = zoom
            self.scrollView.contentOffset = offset
            self.imageView.frame = newImageFrame
        }) { _ in
            self.setupContentInset()
            self.scrollView.contentSize = self.imageView.frame.size
            self.scrollView.minimumZoomScale = self.getMinimumZoomScale(with: newCropRect.size, imageSize: self.imageView.frame.size)
        }
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
    /// 图片已经裁剪或者旋转
    fileprivate var cropOrRotate: Bool {
        return didCrop || rotateState != .portrait
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
    fileprivate var lastScrollViewBounds: CGRect {
        get { return cropContext.lastScrollViewBounds }
        set { cropContext.lastScrollViewBounds = newValue }
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
    /// 旋转方向
    fileprivate var rotateState: RotateState {
        get { return cropContext.rotateState }
        set { cropContext.rotateState = newValue }
    }
}
