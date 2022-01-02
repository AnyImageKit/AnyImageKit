//
//  CanvasMask.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/3.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
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
    
    func draw(in context: CGContext, size: CGSize) {
        guard !paths.isEmpty else { return }
        guard
            let cglayer = CGLayer(context, size: size, auxiliaryInfo: nil),
            let layerContext = cglayer.context else {
            assert(false, "Failed to create CGLayer")
            return
        }
        
        UIGraphicsPushContext(layerContext)
        paths.forEach { path in
            layerContext.saveGState()
            layerContext.scaleBy(x: scale, y: scale)
            path.draw(in: layerContext, size: size)
            layerContext.restoreGState()
        }
        UIGraphicsPopContext()
        
        UIGraphicsPushContext(context)
        context.draw(cglayer, at: .zero)
        UIGraphicsPopContext()
    }
}
