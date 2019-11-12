//
//  PhotoContentView+Pen.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

// MARK: - Public function
extension PhotoContentView {
    
    func canvasUndo() {
        canvas.lastPenImageView.image = penCache.read()
        canvas.reset()
    }
    
    func canvasCanUndo() -> Bool {
        return penCache.hasCache()
    }
}

// MARK: - Internal function
extension PhotoContentView {
    
    func updateCanvasFrame() {
        canvas.frame = CGRect(origin: .zero, size: imageView.bounds.size)
    }
}

// MARK: - CanvasDelegate
extension PhotoContentView: CanvasDelegate {
    
    func canvasDidBeginPen() {
        delegate?.photoDidBeginPen()
    }
    
    func canvasDidEndPen() {
        delegate?.photoDidEndPen()
        
        let screenshot = canvas.screenshot
        canvas.lastPenImageView.image = screenshot
        canvas.reset()
        penCache.write(screenshot)
    }
}

// MARK: - CanvasDataSource
extension PhotoContentView: CanvasDataSource {
    
    func canvasGetScale(_ canvas: Canvas) -> CGFloat {
        return scrollView.zoomScale
    }
}
