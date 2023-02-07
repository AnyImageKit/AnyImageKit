//
//  CapturePreviewContentView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/18.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import CoreMedia
import AVFoundation

final class CapturePreviewContentView: UIView {
    
    var displayLayer: AVSampleBufferDisplayLayer {
        layer as! AVSampleBufferDisplayLayer
    }
    
    override class var layerClass: AnyClass {
        AVSampleBufferDisplayLayer.self
    }
    
    func clear() {
        Thread.runOnMain {
            self.displayLayer.flushAndRemoveImage()
        }
    }
    
    func draw(sampleBuffer: CMSampleBuffer) {
        Thread.runOnMain {
            self.displayLayer.enqueue(sampleBuffer)
        }
    }
}
