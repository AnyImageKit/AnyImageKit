//
//  PhotoEditorContentView+InputText.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/10.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - Internal
extension PhotoEditorContentView {
    
    @discardableResult
    func addText(data: TextData, add: Bool = true) -> TextImageView {
        if data.frame.isEmpty {
            calculateTextFrame(data: data)
            if cropContext.rotateState != .portrait {
                data.rotation = cropContext.rotateState.toPortraitAngle
            }
        }
        
        let textView = TextImageView(data: data)
        textView.transform = textView.calculateTransform()
        if add {
            imageView.insertSubview(textView, belowSubview: cropLayerLeave)
            textImageViews.append(textView)
            addTextGestureRecognizer(textView)
        }
        return textView
    }
    
    /// 裁剪结束时更新UI
    func updateTextFrameWhenCropEnd() {
        let scale = imageView.bounds.width / cropContext.lastImageViewBounds.width
        resetTextView(with: scale)
    }
    
    /// 更新UI
    func resetTextView(with scale: CGFloat) {
        var newTextImageViews: [TextImageView] = []
        for textView in textImageViews {
            let originPoint = textView.data.point
            let originScale = textView.data.scale
            let originRotation = textView.data.rotation
            textView.data.point = .zero
            textView.data.scale = 1.0
            textView.data.rotation = 0.0
            textView.transform = textView.calculateTransform()
            
            var frame = textView.frame
            frame.origin.x *= scale
            frame.origin.y *= scale
            frame.size.width *= scale
            frame.size.height *= scale
            textView.data.frame = frame
            
            let newTextView = addText(data: textView.data, add: false)
            newTextView.data.point = CGPoint(x: originPoint.x * scale, y: originPoint.y * scale)
            newTextView.data.scale = originScale
            newTextView.data.rotation = originRotation
            newTextView.transform = textView.calculateTransform()
            newTextImageViews.append(newTextView)
        }
        
        textImageViews.forEach { $0.removeFromSuperview() }
        textImageViews.removeAll()
        newTextImageViews.forEach {
            imageView.insertSubview($0, belowSubview: cropLayerLeave)
            self.textImageViews.append($0)
            self.addTextGestureRecognizer($0)
        }
    }
    
    func calculateFinalFrame(with scale: CGFloat) {
        for textView in textImageViews {
            let data = textView.data
            let originPoint = data.point
            let originScale = data.scale
            let originRotation = data.rotation
            let originFrame = data.frame
            data.point = .zero
            data.scale = 1.0
            data.rotation = 0.0
            textView.transform = textView.calculateTransform()
            var frame = textView.frame
            frame.origin.x *= scale
            frame.origin.y *= scale
            frame.size.width *= scale
            frame.size.height *= scale
            data.frame = frame
            
            let newTextView = TextImageView(data: data)
            data.point = originPoint.multipliedBy(scale)
            data.scale = originScale
            data.frame = originFrame
            newTextView.transform = textView.calculateTransform()
            data.finalFrame = newTextView.frame
            data.point = originPoint
            data.rotation = originRotation
        }
    }
    
    /// 删除隐藏的TextView
    func removeHiddenTextView() {
        for (idx, textView) in textImageViews.enumerated() {
            if textView.isHidden {
                textView.removeFromSuperview()
                textImageViews.remove(at: idx)
                context.action(.textDidFinishMove(data: textView.data, delete: true))
            }
        }
    }
    
    /// 删除所有TextView
    func removeAllTextView() {
        textImageViews.forEach { $0.removeFromSuperview() }
        textImageViews.removeAll()
    }
    
    /// 显示所有TextView
    func restoreHiddenTextView() {
        textImageViews.forEach{ $0.isHidden = false }
    }
    
    /// 隐藏所有TextView
    func hiddenAllTextView() {
        textImageViews.forEach{ $0.isHidden = true }
    }
    
    /// 取消激活所有TextView
    func deactivateAllTextView() {
        textImageViews.forEach{ $0.setActive(false) }
    }
    
    func updateTextView(with edit: PhotoEditingStack.Edit) {
        let textData = textImageViews.map { $0.data }
        if textData == edit.textData {
            return
        } else if textData.count < edit.textData.count {
            if textData == Array(edit.textData[0..<textImageViews.count]) {
                for i in textData.count..<edit.textData.count {
                    addText(data: edit.textData[i])
                }
            }
        } else {
            if edit.textData == Array(textData[0..<edit.textData.count]) {
                for _ in edit.textData.count..<textData.count {
                    let textView = textImageViews.removeLast()
                    textView.removeFromSuperview()
                }
            }
        }
        if textData != edit.textData { // Just in case
            removeAllTextView()
            edit.textData.forEach { addText(data: $0) }
        }
    }
}

// MARK: - Private
extension PhotoEditorContentView {
    
    /// 计算视图位置
    private func calculateTextFrame(data: TextData) {
        let image = data.image
        let scale = scrollView.zoomScale
        let inset: CGFloat = 0
        let size = CGSize(width: (image.size.width + inset * 2) / scale, height: (image.size.height + inset * 2) / scale)
        
        var x: CGFloat
        var y: CGFloat
        if !cropContext.didCropOrRotate {
            if scrollView.zoomScale == scrollView.minimumZoomScale {
                x = (imageView.bounds.width - size.width) / 2
                y = (imageView.bounds.height - size.height) / 2
            } else {
                let width = UIScreen.main.bounds.width * imageView.bounds.width / imageView.frame.width
                x = abs(scrollView.contentOffset.x) / scale
                x = x + (width - size.width) / 2
                
                var height = UIScreen.main.bounds.height * imageView.bounds.height / imageView.frame.height
                let screenHeight = UIScreen.main.bounds.height / scale
                height = height > screenHeight ? screenHeight : height
                y = scrollView.contentOffset.y / scale
                y = y + (height - size.height) / 2
            }
        } else {
            let reversedCropRect = cropContext.cropRect.size.reversed(!cropContext.rotateState.isPortrait)
            let imageFrameSize = imageView.frame.size
            let contentSize = scrollView.contentSize
            let imageSize = CGSize(width: contentSize.width * imageFrameSize.width / reversedCropRect.width,
                                   height: contentSize.height * imageFrameSize.height / reversedCropRect.height)

            let contentOffset = cropContext.lastCropData.contentOffset
            let offsetX = contentOffset.x * imageSize.width / imageFrameSize.width
            let offsetY = contentOffset.y * imageSize.height / imageFrameSize.height
            
            let width = cropContext.cropRealRect.width * imageView.bounds.width / imageView.frame.width
            x = offsetX / scale
            x = x + (width - size.width) / 2
            
            let height = cropContext.cropRealRect.height * imageView.bounds.height / imageView.frame.height
            y = offsetY / scale
            y = y + (height - size.height) / 2
        }
        data.frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
    }
    
    /// 添加手势
    private func addTextGestureRecognizer(_ textView: TextImageView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTextSingleTap(_:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onTextPan(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(onTextPinch(_:)))
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(onTextRotation(_:)))
        tap.require(toFail: pan)
        tap.delegate = self
        pan.delegate = self
        pinch.delegate = self
        rotation.delegate = self
        textView.addGestureRecognizer(tap)
        textView.addGestureRecognizer(pan)
        textView.addGestureRecognizer(pinch)
        textView.addGestureRecognizer(rotation)
    }
    
    /// 允许开始响应手势
    private func shouldBeginGesture(in textView: TextImageView) -> Bool {
        if textView.isActive { return true }
        for view in textImageViews {
            if !view.isGestureEnded {
                return false
            }
        }
        return true
    }
    
    /// 激活视图
    @discardableResult
    private func activeTextViewIfPossible(_ textView: TextImageView) -> Bool {
        if !shouldBeginGesture(in: textView) { return false }
        for view in textImageViews {
            if view == textView && !textView.isActive {
                bringTextViewToFront(textView)
                imageView.bringSubviewToFront(cropLayerLeave)
            }
            view.setActive(view == textView)
        }
        return true
    }
    
    private func bringTextViewToFront(_ textView: TextImageView) {
        imageView.bringSubviewToFront(textView)
        context.action(.textBringToFront(textView.data))
        if let idx = textImageViews.firstIndex(of: textView) {
            textImageViews.remove(at: idx)
            textImageViews.append(textView)
        }
    }
}

// MARK: - Target
extension PhotoEditorContentView {
    
    /// 单击手势
    @objc private func onTextSingleTap(_ tap: UITapGestureRecognizer) {
        guard let textView = tap.view as? TextImageView else { return }
        if !shouldBeginGesture(in: textView) { return }
        if !textView.isActive {
            activeTextViewIfPossible(textView)
        } else {
            // 隐藏当前TextView，进入编辑页面
            textView.isHidden = true
            context.action(.textWillBeginEdit(textView.data))
        }
    }
    
    /// 拖拽手势
    @objc private func onTextPan(_ pan: UIPanGestureRecognizer) {
        guard let textView = pan.view as? TextImageView else { return }
        guard activeTextViewIfPossible(textView) else { return }
        
        if pan.state == .began {
            textView.data.pointBeforePan = textView.data.point
        }
        
        let scale = scrollView.zoomScale
        let point = textView.data.point
        let newPoint = pan.translation(in: self)
        switch cropContext.rotateState {
        case .portrait:
            textView.data.point = CGPoint(x: point.x + newPoint.x / scale, y: point.y + newPoint.y / scale)
        case .upsideDown:
            textView.data.point = CGPoint(x: point.x - newPoint.x / scale, y: point.y - newPoint.y / scale)
        case .landscapeLeft:
            textView.data.point = CGPoint(x: point.x - newPoint.y / scale, y: point.y + newPoint.x / scale)
        case .landscapeRight:
            textView.data.point = CGPoint(x: point.x + newPoint.y / scale, y: point.y - newPoint.x / scale)
        }
        textView.transform = textView.calculateTransform()
        pan.setTranslation(.zero, in: self)
        
        switch pan.state {
        case .began:
            showTrashView()
            bringTextViewToFront(textView)
            context.action(.textWillBeginMove(textView.data))
        case .changed:
            check(targetView: textView, inTrashView: pan.location(in: self))
        default:
            var delete = false
            if textTrashView.state == .remove && textTrashView.frame.contains(pan.location(in: self)) { // 判断在删除区域
                delete = true
            } else if !cropLayerLeave.displayRect.contains(pan.location(in: cropLayerLeave)) { // 判断超出图片区域
                UIView.animate(withDuration: 0.25) {
                    textView.data.point = textView.data.pointBeforePan
                    textView.transform = textView.calculateTransform()
                } completion: { (_) in
                    self.imageView.bringSubviewToFront(self.cropLayerLeave)
                }
            } else {
                imageView.bringSubviewToFront(cropLayerLeave)
            }
            hideTrashView()
            context.action(.textDidFinishMove(data: textView.data, delete: delete))
        }
    }
    
    /// 捏合手势
    @objc private func onTextPinch(_ pinch: UIPinchGestureRecognizer) {
        guard let textView = pinch.view as? TextImageView else { return }
        guard activeTextViewIfPossible(textView) else { return }
        
        let scale = textView.data.scale + (pinch.scale - 1.0)
        if scale < textView.data.scale || textView.frame.width < imageView.bounds.width*2.0 {
            textView.data.scale = scale
            textView.transform = textView.calculateTransform()
        }
        pinch.scale = 1.0
    }
    
    /// 旋转手势
    @objc private func onTextRotation(_ rotation: UIRotationGestureRecognizer) {
        guard let textView = rotation.view as? TextImageView else { return }
        guard activeTextViewIfPossible(textView) else { return }
        
        textView.data.rotation += rotation.rotation
        textView.transform = textView.calculateTransform()
        rotation.rotation = 0.0
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PhotoEditorContentView: UIGestureRecognizerDelegate {
    
    /// 允许多个手势同时响应
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = gestureRecognizer.view as? TextImageView,
            let otherView = otherGestureRecognizer.view as? TextImageView
            else { return false }
        guard view == otherView, view.isActive else { return false }
        return true
    }
}

// MARK: - Trash view
extension PhotoEditorContentView {
    
    private func showTrashView() {
        textTrashView.snp.remakeConstraints { maker in
            if #available(iOS 11.0, *) {
                maker.top.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(50)
            } else {
                maker.top.equalTo(self.snp.bottom)
            }
            maker.centerX.equalToSuperview()
            maker.width.greaterThanOrEqualTo(160)
            maker.height.equalTo(80)
        }
        self.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.25) {
            self.textTrashView.alpha = 1
            self.textTrashView.snp.updateConstraints { update in
                if #available(iOS 11.0, *) {
                    update.top.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-80-30)
                } else {
                    update.top.equalTo(self.snp.bottom).offset(-80-30)
                }
            }
            self.layoutIfNeeded()
        }
    }
    
    private func hideTrashView() {
        UIView.animate(withDuration: 0.25) {
            self.textTrashView.alpha = 0
        } completion: { _ in
            self.textTrashView.state = .idle
        }
    }
    
    private func check(targetView: UIView, inTrashView point: CGPoint) {
        guard textTrashView.alpha == 1 else { return }
        if textTrashView.frame.contains(point) { // move in
            textTrashView.state = .remove
            UIView.animate(withDuration: 0.25) {
                targetView.alpha = 0.25
            }
        } else if textTrashView.state == .remove { // move out
            hideTrashView()
            UIView.animate(withDuration: 0.25) {
                targetView.alpha = 1.0
            }
        }
    }
}
