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
    
    private lazy var previewContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var previewMaskView: CapturePreviewMaskView = {
        let view = CapturePreviewMaskView(frame: .zero)
        return view
    }()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(previewContentView)
        addSubview(previewMaskView)
        previewContentView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        previewMaskView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

// MARK: - Connect
extension CapturePreviewView {
    
    func connect(to session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewContentView.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        previewLayer.frame = bounds
    }
    
    func disconnect(from session: AVCaptureSession) {
        guard previewLayer?.session == session else {
            return
        }
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }
}

// MARK: - Animation
extension CapturePreviewView {
    
    func hideMask(animated: Bool) {
        let duration = animated ? 0.25 : 0
        let timingParameters = UICubicTimingParameters(animationCurve: .easeInOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        animator.addAnimations {
            self.previewMaskView.topMaskView.alpha = 0
            self.previewMaskView.bottomMaskView.alpha = 0
        }
        animator.startAnimation()
    }
    
    func showMask(animated: Bool) {
        let duration = animated ? 0.25 : 0
        let timingParameters = UICubicTimingParameters(animationCurve: .easeInOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        animator.addAnimations {
            self.previewMaskView.topMaskView.alpha = 1.0
            self.previewMaskView.bottomMaskView.alpha = 1.0
        }
        animator.startAnimation()
    }
}
