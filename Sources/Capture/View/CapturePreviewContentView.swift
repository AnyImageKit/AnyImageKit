//
//  CapturePreviewContentView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/18.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import CoreImage
import MetalKit

final class CapturePreviewContentView: MTKView {
    
    var videoGravity: VideoGravity = .resizeAspectFill
    
    private var contentImage: CIImage?
    private lazy var context: CIContext = {
        if let mtlDevice = self.device {
            return CIContext(mtlDevice: mtlDevice)
        } else {
            return CIContext()
        }
    }()
    private let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    
    init(frame: CGRect) {
        let device = MTLCreateSystemDefaultDevice()
        super.init(frame: frame, device: device)
        self.delegate = self
        self.framebufferOnly = false
        self.enableSetNeedsDisplay = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CapturePreviewContentView {
    
    func draw(image: CIImage) {
        DispatchQueue.main.async {
            self.contentImage = image
            self.setNeedsDisplay()
        }
    }
}

extension CapturePreviewContentView: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard
            let drawable: CAMetalDrawable = currentDrawable,
            let image: CIImage = contentImage,
            let commandBuffer: MTLCommandBuffer = device?.makeCommandQueue()?.makeCommandBuffer()
            else {
                return
        }
        var scaleX: CGFloat = 0
        var scaleY: CGFloat = 0
        var translationX: CGFloat = 0
        var translationY: CGFloat = 0
        switch videoGravity {
        case .resize:
            scaleX = drawableSize.width / image.extent.width
            scaleY = drawableSize.height / image.extent.height
        case .resizeAspect:
            let scale: CGFloat = min(drawableSize.width / image.extent.width, drawableSize.height / image.extent.height)
            scaleX = scale
            scaleY = scale
            translationX = (drawableSize.width - image.extent.width * scale) / scaleX / 2
            translationY = (drawableSize.height - image.extent.height * scale) / scaleY / 2
        case .resizeAspectFill:
            let scale: CGFloat = max(drawableSize.width / image.extent.width, drawableSize.height / image.extent.height)
            scaleX = scale
            scaleY = scale
            translationX = (drawableSize.width - image.extent.width * scale) / scaleX / 2
            translationY = (drawableSize.height - image.extent.height * scale) / scaleY / 2
        }
        let bounds = CGRect(origin: .zero, size: drawableSize)
        let scaledImage: CIImage = image
            .transformed(by: CGAffineTransform(translationX: translationX, y: translationY))
            .transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        context.render(scaledImage, to: drawable.texture, commandBuffer: commandBuffer, bounds: bounds, colorSpace: colorSpace)
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension CapturePreviewContentView {
    
    enum VideoGravity {
        
        case resizeAspect
        case resizeAspectFill
        case resize
    }
}
