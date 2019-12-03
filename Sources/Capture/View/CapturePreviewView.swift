//
//  CapturePreviewView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/7/22.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import AVFoundation

final class CapturePreviewView: UIView {
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .black
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    func connect(to session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        previewLayer.frame = bounds
    }
    
    func disconnect() {
        previewLayer?.removeFromSuperlayer()
    }
}
