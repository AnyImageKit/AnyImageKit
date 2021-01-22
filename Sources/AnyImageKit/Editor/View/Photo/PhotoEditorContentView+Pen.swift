//
//  PhotoEditorContentView+Pen.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

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
