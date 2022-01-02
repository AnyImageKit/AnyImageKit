//
//  BlurredMask.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/3.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

struct BlurredMask {
    
    let paths: [DrawnPath]
    let scale: CGFloat
    let blurImage: UIImage
    
    init(paths: [DrawnPath], scale: CGFloat, blurImage: UIImage) {
        self.paths = paths
        self.scale = scale
        self.blurImage = blurImage
    }
}

// MARK: - GraphicsDrawing
extension BlurredMask: GraphicsDrawing {
    
    func draw(in context: CGContext, size: CGSize) {
        guard !paths.isEmpty else { return }
        guard
            let cglayer = CGLayer(context, size: size, auxiliaryInfo: nil),
            let layerContext = cglayer.context else {
            assert(false, "Failed to create CGLayer")
            return
        }
        
        UIGraphicsPushContext(layerContext)
        let ciContext = CIContext(cgContext: layerContext, options: [:])
        let ciImage = CIImage(image: blurImage)!
        let blurScale = calculateBlurImageScale(canvasSize: size, imageSize: ciImage.extent.size)
        let offsetX = (ciImage.extent.size.width * blurScale - size.width) / 2
        let offsetY = (ciImage.extent.size.height * blurScale - size.height) / 2
        
        paths.forEach { path in
            layerContext.saveGState()
            layerContext.scaleBy(x: scale , y: scale)
            path.draw(in: layerContext, size: size)
            layerContext.restoreGState()
        }
        
        layerContext.saveGState()
        layerContext.setBlendMode(.sourceIn)
        layerContext.translateBy(x: -offsetX, y: size.height + offsetY)
        layerContext.scaleBy(x: blurScale, y: -blurScale)
        ciContext.draw(ciImage, in: ciImage.extent, from: ciImage.extent)
        layerContext.restoreGState()
        UIGraphicsPopContext()
        
        UIGraphicsPushContext(context)
        context.draw(cglayer, at: .zero)
        UIGraphicsPopContext()
    }
    
    private func calculateBlurImageScale(canvasSize: CGSize, imageSize: CGSize) -> CGFloat {
        if canvasSize.width < imageSize.width && canvasSize.height < imageSize.height { return 1.0 }
        if canvasSize.width < canvasSize.height {
            return canvasSize.height / imageSize.height
        } else {
            return canvasSize.width / imageSize.width
        }
    }
}
