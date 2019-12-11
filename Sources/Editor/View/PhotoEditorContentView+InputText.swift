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
    
    func addText(_ text: String, image: UIImage) {
        let scale = scrollView.zoomScale
        let offset: CGFloat = 20 // TODO: 内部也需要offset
        let size = CGSize(width: (image.size.width) / scale + offset, height: (image.size.height) / scale + offset)
        
        var x: CGFloat
        var y: CGFloat
        if !didCrop {
            x = 0
            y = (imageView.frame.height - size.height) / 2
        } else { // TODO: 竖图有问题
            x = lastCropData.contentOffset.x / scrollView.zoomScale
            x = x + (cropRealRect.width / scrollView.zoomScale - size.width) / 2
            y = lastCropData.contentOffset.y / scrollView.zoomScale
            y = y + (cropRealRect.height / scrollView.zoomScale - size.height) / 2
        }
        let frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
        let textView = TextImageView(frame: frame, text: text, image: image)
        textView.contentMode = .center
        imageView.addSubview(textView)
        textImages.append(textView)
        addTextGestureRecognizer(textView)
    }
    
    func updateTextFrame(_ startCrop: Bool) {
        let scale: CGFloat
        if startCrop {
            scale = (UIScreen.main.bounds.width - cropX * 2) / UIScreen.main.bounds.width
        } else {
            scale = UIScreen.main.bounds.width / (UIScreen.main.bounds.width - cropX * 2)
        }
        // TODO: 竖图有问题
        for textView in textImages {
            var frame = textView.frame
            frame.origin.x *= scale
            frame.origin.y *= scale
            frame.size.width *= scale
            frame.size.height *= scale
            textView.frame = frame
            textView.layoutIfNeeded()
        }
    }
}

extension PhotoEditorContentView {
    
    /// 添加手势
    private func addTextGestureRecognizer(_ textView: TextImageView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTextSingleTap(_:)))
        let pen = UIPanGestureRecognizer(target: self, action: #selector(onTextPan(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(onTextPinch(_:)))
        textView.addGestureRecognizer(tap)
        textView.addGestureRecognizer(pen)
        textView.addGestureRecognizer(pinch)
    }
}

// MARK: - Target
extension PhotoEditorContentView {
    
    @objc private func onTextSingleTap(_ tap: UITapGestureRecognizer) {
        guard let textView = tap.view as? TextImageView else { return }
        textView.setSelected(!textView.isSelected)
    }
    
    @objc private func onTextPan(_ pan: UIPanGestureRecognizer) {
        
    }
    
    @objc private func onTextPinch(_ pinch: UIPinchGestureRecognizer) {
        
    }
}
