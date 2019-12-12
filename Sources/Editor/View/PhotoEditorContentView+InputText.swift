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
            x = (imageView.frame.width - size.width) / 2
            y = (imageView.frame.height - size.height) / 2
        } else { // TODO: 竖图有问题
            let width = cropRealRect.width * imageView.bounds.width / imageView.frame.width
//            let height = width * imageView.bounds.height / imageView.bounds.width
            var height = cropRealRect.height * imageView.bounds.height / imageView.frame.height
            height = height > UIScreen.main.bounds.height ? UIScreen.main.bounds.height : height
            x = abs(imageView.frame.origin.x) / scale
            x = x + (width - size.width) / 2
            
            y = lastCropData.contentOffset.y / scale
            y = y + scrollView.contentOffset.y / scale
            y = y + (height - size.height) / 2
            
//            y = y + (cropRealRect.height / scrollView.zoomScale - size.height) / 2
//            print(scrollView.contentOffset)
        }
        let frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
        let textView = TextImageView(frame: frame, text: text, image: image)
        textView.contentMode = .center
        imageView.addSubview(textView)
        textImages.append(textView)
        addTextGestureRecognizer(textView)
    }
    
    func updateTextFrame(_ startCrop: Bool) {
        // 用当前的宽除之前的宽就是缩放比例
        let scale: CGFloat = imageView.bounds.width / lastImageViewBounds.width
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
