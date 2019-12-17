//
//  CaptureToolView.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/12.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class CaptureToolView: UIView {
    
    private(set) lazy var captureButton: CaptureButton = {
        let view = CaptureButton(frame: .zero)
        return view
    }()
    
    private(set) lazy var cancelButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.setTitle("Cancel", for: .normal)
        view.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return view
    }()
    
    private(set) lazy var switchButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.setTitle("Switch", for: .normal)
        view.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
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
        let layoutGuide1 = UILayoutGuide()
        let layoutGuide2 = UILayoutGuide()
        addLayoutGuide(layoutGuide1)
        addLayoutGuide(layoutGuide2)
        addSubview(captureButton)
        addSubview(cancelButton)
        addSubview(switchButton)
        
        layoutGuide1.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        captureButton.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.width.equalTo(captureButton.snp.height)
            maker.center.equalToSuperview()
        }
        layoutGuide2.snp.makeConstraints { maker in
            maker.left.equalTo(captureButton.snp.right)
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.width.equalTo(layoutGuide1.snp.width)
        }
        
        cancelButton.snp.makeConstraints { maker in
            maker.centerY.equalTo(layoutGuide1.snp.centerY)
            maker.left.equalTo(layoutGuide1.snp.left).offset(8)
        }
        switchButton.snp.makeConstraints { maker in
            maker.centerY.equalTo(layoutGuide2.snp.centerY)
            maker.right.equalTo(layoutGuide2.snp.right).offset(-8)
        }
    }
}

// MARK: - Animation
extension CaptureToolView {
    
    func showButtons(animated: Bool) {
        let duration = animated ? 0.25 : 0
        let timingParameters = UICubicTimingParameters(animationCurve: .easeInOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        animator.addAnimations {
            self.cancelButton.alpha = 1.0
            self.switchButton.alpha = 1.0
        }
        animator.addCompletion { _ in
            self.cancelButton.isEnabled = true
            self.switchButton.isEnabled = true
        }
        animator.startAnimation()
    }
    
    func hideButtons(animated: Bool) {
        let duration = animated ? 0.25 : 0
        let timingParameters = UICubicTimingParameters(animationCurve: .easeInOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        animator.addAnimations {
            self.cancelButton.alpha = 0.0
            self.switchButton.alpha = 0.0
        }
        animator.addCompletion { _ in
            self.cancelButton.isEnabled = false
            self.switchButton.isEnabled = false
        }
        animator.startAnimation()
    }
}
