//
//  TextMask.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/29.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

struct TextMask {
    
    let data: TextData
    let scale: CGFloat
    
    init(data: TextData, scale: CGFloat) {
        self.data = data
        self.scale = scale
    }
}

// MARK: - GraphicsDrawing
extension TextMask: GraphicsDrawing {
    
    func draw(in context: CGContext, canvasSize: CGSize) {
        guard
            let cgImage = data.image.cgImage else {
            assert(false, "Failed to create CGLayer")
            return
        }

        let frame = data.finalFrame.multipliedBy(scale)

        context.saveGState()
        context.translateBy(x: frame.midX, y: frame.midY)
        context.rotate(by: data.rotation)

        let clipPath = UIBezierPath(rect: CGRect(origin: CGPoint(x: -(frame.width/2), y: -(frame.height/2)), size: frame.size))
        context.saveGState()
        clipPath.addClip()
        
        context.scaleBy(x: 1, y: -1)
        context.draw(cgImage, in: CGRect(x: -(frame.width/2), y: frame.height/2, width: frame.width, height: frame.height), byTiling: true)
        
        context.restoreGState()
        context.restoreGState()
    }
}

