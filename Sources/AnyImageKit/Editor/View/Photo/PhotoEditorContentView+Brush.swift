//
//  PhotoEditorContentView+Brush.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - CanvasDelegate
extension PhotoEditorContentView: CanvasDelegate {
    
    func canvasDidBeginDraw() {
        context.action(.brushBeginDraw)
    }
    
    func canvasDidEndDraw() {
        context.action(.brushFinishDraw(canvas.drawnPaths.map { BrushData(drawnPath: $0) }))
    }
}

// MARK: - CanvasDataSource
extension PhotoEditorContentView: CanvasDataSource {
    
    func canvasGetLineWidth(_ canvas: Canvas) -> CGFloat {
        let scale = scrollView.zoomScale
        return options.brushWidth / scale
    }
}
