//
//  CanvasMask.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/3.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

struct CanvasMask {
    
    let paths: [DrawnPath]
    let scale: CGFloat
    
    init(paths: [DrawnPath], scale: CGFloat) {
        self.paths = paths
        self.scale = scale
    }
}

// MARK: - GraphicsDrawing
extension CanvasMask: GraphicsDrawing {
    
    func draw(in context: CGContext, canvasSize: CGSize) {
        guard !paths.isEmpty else { return }
        let mainContext = context
        let size = canvasSize
        
        guard
            let cglayer = CGLayer(mainContext, size: size, auxiliaryInfo: nil),
            let layerContext = cglayer.context else {
            assert(false, "Failed to create CGLayer")
            return
        }
        
        UIGraphicsPushContext(layerContext)
        
        paths.forEach { path in
            layerContext.saveGState()
            layerContext.scaleBy(x: scale, y: scale)
            path.draw(in: layerContext, canvasSize: canvasSize)
            layerContext.restoreGState()
        }
        
        UIGraphicsPopContext()
        UIGraphicsPushContext(mainContext)
        mainContext.draw(cglayer, at: .zero)
        UIGraphicsPopContext()
    }
}
