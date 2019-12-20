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
//        view.contentView.backgroundColor = .white
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
        let flip = CATransition()
        flip.duration = 0.35
        flip.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        flip.type = CATransitionType(rawValue: "oglFlip")
        flip.subtype = isIn ? .fromLeft : .fromRight
        flip.delegate = self
        layer.add(flip, forKey: "flip")
    }
}

extension CapturePreviewView: CAAnimationDelegate {
    
    func animationDidStart(_ anim: CAAnimation) {
        flipMaskView.alpha = 1
        flipMaskView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.flipMaskView.alpha = 0
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.75) {
            UIView.animate(withDuration: 0.25, animations: {
                self.flipMaskView.alpha = 1
            }) { _ in
                self.flipMaskView.isHidden = true
            }
        }
    }
}
