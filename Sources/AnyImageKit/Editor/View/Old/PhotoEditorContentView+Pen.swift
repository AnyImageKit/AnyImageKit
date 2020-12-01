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
    
    func updateCanvasFrame() {
        canvas.frame = CGRect(origin: .zero, size: imageView.bounds.size)
        mosaic?.frame = CGRect(origin: .zero, size: imageView.bounds.size)
        mosaic?.layoutSubviews()
    }
}

// MARK: - CanvasDelegate
extension PhotoEditorContentView: CanvasDelegate {
    
    func canvasDidBeginPen() {
        context.action(.penBeginDraw)
    }
    
    func canvasDidEndPen() {
        context.action(.penFinishDraw(canvas.drawnPaths.map { PenData(drawnPath: $0) }))
    }
}

// MARK: - CanvasDataSource
extension PhotoEditorContentView: CanvasDataSource {
    
    func canvasGetLineWidth(_ canvas: Canvas) -> CGFloat {
        let scale = scrollView.zoomScale
        return options.penWidth / scale
    }
}
