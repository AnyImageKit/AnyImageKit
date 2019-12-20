//
//  CapturePreviewView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/7/22.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import CoreMedia
import MetalKit

final class CapturePreviewView: UIView {
    
    private lazy var previewContentView: PreviewContentView = {
        let view = PreviewContentView(frame: .zero)
        return view
    }()
    
    private lazy var previewMaskView: CapturePreviewMaskView = {
        let view = CapturePreviewMaskView(frame: .zero)
        return view
    }()
    
    private lazy var flipMaskView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: effect)
        view.contentView.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
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
        addSubview(flipMaskView)
        previewContentView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        previewMaskView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        flipMaskView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
}

// MARK: - Preview Buffer
extension CapturePreviewView {
    
    func draw(_ sampleBuffer: CMSampleBuffer) {
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let image = CIImage(cvImageBuffer: imageBuffer)
            previewContentView.draw(image: image)
        }
    }
}

// MARK: - Animation
extension CapturePreviewView {
    
    func hideToolMask(animated: Bool) {
        let duration = animated ? 0.25 : 0
        let timingParameters = UICubicTimingParameters(animationCurve: .easeInOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        animator.addAnimations {
            self.previewMaskView.topMaskView.alpha = 0
            self.previewMaskView.bottomMaskView.alpha = 0
        }
        animator.startAnimation()
    }
    
    func showToolMask(animated: Bool) {
        let duration = animated ? 0.25 : 0
        let timingParameters = UICubicTimingParameters(animationCurve: .easeInOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        animator.addAnimations {
            self.previewMaskView.topMaskView.alpha = 1.0
            self.previewMaskView.bottomMaskView.alpha = 1.0
        }
        animator.startAnimation()
    }
    
    func flip(isIn: Bool) {
//        let animation1Duration = 0.2
        let animation2Duration = 0.35
//        let animation3Duration = 0.2
        
//        let animation1 = CABasicAnimation(keyPath: "transform.scale")
//        animation1.duration = animation1Duration
//        animation1.fromValue = 1.0
//        animation1.toValue = 0.9
//        animation1.isRemovedOnCompletion = false
//        animation1.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let animation2 = CATransition()
        animation2.duration = animation2Duration
//        animation2.beginTime = animation1Duration
        animation2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation2.type = CATransitionType(rawValue: "oglFlip")
        animation2.subtype = isIn ? .fromLeft : .fromRight
        animation2.delegate = self
        
//        let animation3 = CABasicAnimation(keyPath: "transform.scale")
//        animation3.duration = animation3Duration
//        animation3.beginTime = animation1Duration + animation2Duration
//        animation3.fromValue = 0.9
//        animation3.toValue = 1.0
//        animation3.isRemovedOnCompletion = false
//        animation3.timingFunction = CAMediaTimingFunction(name: .linear)
//
//        let animationGroup = CAAnimationGroup()
//        animationGroup.animations = [animation1]
//        animationGroup.duration = animation1Duration + animation3Duration
//        animationGroup.fillMode = .forwards
//        animationGroup.isRemovedOnCompletion = false
//        animationGroup.delegate = self
        
        layer.add(animation2, forKey: "flip")
    }
}

extension CapturePreviewView: CAAnimationDelegate {
    
    func animationDidStart(_ anim: CAAnimation) {
        flipMaskView.isHidden = false
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        flipMaskView.isHidden = true
    }
}
