//
//  PhotoEditorContentView+Pen.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

// MARK: - Public function
extension PhotoEditorContentView {
    
    func canvasUndo() {
        canvas.undo()
    }
    
    func canvasCanUndo() -> Bool {
        return true
//        return penCache.hasDiskCache()
    }
    
    func updateCanvasFrame() {
        canvas.frame = CGRect(origin: .zero, size: imageView.bounds.size)
        mosaic?.frame = CGRect(origin: .zero, size: imageView.bounds.size)
        mosaic?.layoutSubviews()
    }
}

// MARK: - CanvasDelegate
extension PhotoEditorContentView: CanvasDelegate {
    
    func canvasDidBeginPen() {
        delegate?.photoDidBeginPen()
    }
    
    func canvasDidEndPen() {
        let screenshot = canvas.screenshot()
        // TODO: Cache
        penCache.write(screenshot)
        
        delegate?.photoDidEndPen()
    }
}

// MARK: - CanvasDataSource
extension PhotoEditorContentView: CanvasDataSource {
    
    func canvasGetLineWidth(_ canvas: Canvas) -> CGFloat {
        let scale = scrollView.zoomScale
        return options.penWidth / scale
    }
}
