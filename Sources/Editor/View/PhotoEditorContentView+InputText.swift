//
//  PhotoEditorContentView+InputText.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/10.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

// MARK: - Internal
extension PhotoEditorContentView {
    
    /// 添加一个TextView
    func addText(_ text: String, colorIdx: Int, image: UIImage) {
        let scale = scrollView.zoomScale
        let offset: CGFloat = 20 // TODO: 内部也需要offset
        let size = CGSize(width: (image.size.width) / scale + offset, height: (image.size.height) / scale + offset)
        
        var x: CGFloat
        var y: CGFloat
        if !didCrop {
            x = (imageView.frame.width - size.width) / 2
            y = (imageView.frame.height - size.height) / 2
        } else {
            let width = cropRealRect.width * imageView.bounds.width / imageView.frame.width
            x = abs(imageView.frame.origin.x) / scale
            x = x + (width - size.width) / 2
            
            var height = cropRealRect.height * imageView.bounds.height / imageView.frame.height
            let screenHeight = UIScreen.main.bounds.height / scale
            height = height > screenHeight ? screenHeight : height
            y = lastCropData.contentOffset.y / scale
            y = y + scrollView.contentOffset.y / scale
            y = y + (height - size.height) / 2
        }
        let frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
        let textView = TextImageView(frame: frame, text: text, colorIdx: colorIdx, image: image)
        textView.contentMode = .center
        imageView.addSubview(textView)
        textImageViews.append(textView)
        addTextGestureRecognizer(textView)
    }
    
    /// 更新TextView的布局
    func updateTextFrame(_ startCrop: Bool) {
        // 用当前的宽除之前的宽就是缩放比例
        let scale: CGFloat = imageView.bounds.width / lastImageViewBounds.width
        for textView in textImageViews {
            var frame = textView.frame
            frame.origin.x *= scale
            frame.origin.y *= scale
            frame.size.width *= scale
            frame.size.height *= scale
            textView.frame = frame
            textView.layoutIfNeeded()
        }
    }
    
    /// 删除隐藏的视图
    func removeHiddenTextView() {
        for (idx, textView) in textImageViews.enumerated() {
            if textView.tag == -1 {
                textImageViews.remove(at: idx)
                return
            }
        }
    }
    
    /// 恢复删除的视图
    func restoreHiddenTextView() {
        for textView in textImageViews {
            if textView.tag == -1 {
                textView.tag = 0
                textView.isHidden = false
                return
            }
        }
    }
}

extension PhotoEditorContentView {
    
    /// 添加手势
    private func addTextGestureRecognizer(_ textView: TextImageView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTextSingleTap(_:)))
        let pen = UIPanGestureRecognizer(target: self, action: #selector(onTextPan(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(onTextPinch(_:)))
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(onTextRotation(_:)))
        tap.delegate = self
        pen.delegate = self
        pinch.delegate = self
        rotation.delegate = self
        textView.addGestureRecognizer(tap)
        textView.addGestureRecognizer(pen)
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
            view.setActive(view == textView)
            if view == textView {
                imageView.bringSubviewToFront(textView)
            }
        }
        return true
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
            textView.tag = -1
            textView.isHidden = true
            delegate?.inputTextWillBeginEdit(textView.text, colorIdx: textView.colorIdx)
        }
    }
    
    /// 拖拽手势
    @objc private func onTextPan(_ pan: UIPanGestureRecognizer) {
        guard let textView = pan.view as? TextImageView else { return }
        guard activeTextViewIfPossible(textView) else { return }
        
        let point = pan.translation(in: self)
        textView.point = CGPoint(x: textView.point.x + point.x, y: textView.point.y + point.y)
        textView.transform = textView.calculateTransform()
        pan.setTranslation(.zero, in: self)
    }
    
    /// 捏合手势
    @objc private func onTextPinch(_ pinch: UIPinchGestureRecognizer) {
        guard let textView = pinch.view as? TextImageView else { return }
        guard activeTextViewIfPossible(textView) else { return }
        
        let scale = textView.scale + (pinch.scale - 1.0)
        if 0.5 <= scale && scale <= 2.0 {
            textView.scale = scale
            textView.transform = textView.calculateTransform()
        }
        pinch.scale = 1.0
    }
    
    /// 旋转手势
    @objc private func onTextRotation(_ rotation: UIRotationGestureRecognizer) {
        guard let textView = rotation.view as? TextImageView else { return }
        guard activeTextViewIfPossible(textView) else { print(1); return }
        
        textView.rotation += rotation.rotation
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
