//
//  CaptureFocusView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/1/13.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

final class CaptureFocusView: UIView {
    
    private(set) var isFocusing: Bool = false
    private var isAuto: Bool = false
    
    // up = 0, down = 1
    var value: CGFloat {
        return exposureView.value
    }
    
    var orientation: DeviceOrientation {
        return exposureView.orientation
    }
    
    private lazy var rectView: CaptureFocusRectView = {
        let view = CaptureFocusRectView(frame: .zero, options: options)
        view.isHidden = true
        return view
    }()
    
    private lazy var exposureView: CaptureExposureView = {
        let view = CaptureExposureView(frame: .zero, options: options)
        view.isHidden = true
        return view
    }()
    
    private let options: CaptureOptionsInfo
    private var timer: Timer?
    
    init(frame: CGRect, options: CaptureOptionsInfo) {
        self.options = options
        super.init(frame: frame)
        setupView()
        isUserInteractionEnabled = false
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(rectView)
        addSubview(exposureView)
        
        rectView.snp.makeConstraints { maker in
            maker.top.left.equalToSuperview()
            maker.width.height.equalTo(75)
        }
        exposureView.snp.makeConstraints { maker in
            maker.left.equalTo(rectView.snp.right).offset(5)
            maker.centerY.equalTo(rectView)
            maker.width.equalTo(27)
            maker.height.equalTo(145)
        }
    }
}

// MARK: - Public function
extension CaptureFocusView {
    
    func focusing(at point: CGPoint, isAuto: Bool = false, isForce: Bool = false) {
        if !isForce && isAuto && isFocusing { return }
        self.isAuto = isAuto
        stopTimer()
        self.alpha = 0.5
        isFocusing = true
        exposureView.resotre()
        rectView.isHidden = false
        exposureView.isHidden = isAuto
        
        let width: CGFloat = isAuto ? frame.width/3 : 75
        let offsetX = point.x * bounds.width - width / 2
        let offsetY = point.y * bounds.height - width / 2
        rectView.snp.updateConstraints { maker in
            maker.width.height.equalTo(width)
            maker.top.equalToSuperview().offset(offsetY)
            maker.left.equalToSuperview().offset(offsetX)
        }
        rectView.setNeedsDisplay()
        exposureView.point = point
        updateExposureView()
        
        let rectViewScale: CGFloat = isAuto ? 1.1 : 1.6
        rectView.transform = CGAffineTransform(scaleX: rectViewScale, y: rectViewScale)
        exposureView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
            self.rectView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.exposureView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        startTimer()
    }
    
    func setLight(_ value: CGFloat) {
        guard !isAuto else { return }
        stopTimer()
        self.alpha = 1.0
        exposureView.setValue(value)
        startTimer()
    }
    
    func rotate(to orientation: DeviceOrientation, animated: Bool) {
        startTimer()
        self.alpha = 1.0
        exposureView.prepare(orientation: orientation, animated: animated) { [weak self] in
            guard let self = self else { return }
            self.updateExposureView()
            self.exposureView.rotate(animated: animated)
        }
    }
    
    private func updateExposureView() {
        exposureView.snp.remakeConstraints { maker in
            switch exposureView.orientation {
            case .portrait:
                if exposureView.point.x < 0.8 {
                    maker.left.equalTo(rectView.snp.right).offset(5)
                } else {
                    maker.right.equalTo(rectView.snp.left).offset(-5)
                }
                maker.centerY.equalTo(rectView)
                maker.width.equalTo(27)
                maker.height.equalTo(145)
            case .portraitUpsideDown:
                if exposureView.point.x > 0.2 {
                    maker.right.equalTo(rectView.snp.left).offset(-5)
                } else {
                    maker.left.equalTo(rectView.snp.right).offset(5)
                }
                maker.centerY.equalTo(rectView)
                maker.width.equalTo(27)
                maker.height.equalTo(145)
            case .landscapeLeft:
                if exposureView.point.y < 0.7 {
                    maker.top.equalTo(rectView.snp.bottom).offset(5)
                } else {
                    maker.bottom.equalTo(rectView.snp.top).offset(-5)
                }
                maker.centerX.equalTo(rectView)
                maker.width.equalTo(145)
                maker.height.equalTo(27)
            case .landscapeRight:
                if exposureView.point.y > 0.25 {
                    maker.bottom.equalTo(rectView.snp.top).offset(-5)
                } else {
                    maker.top.equalTo(rectView.snp.bottom).offset(5)
                }
                maker.centerX.equalTo(rectView)
                maker.width.equalTo(145)
                maker.height.equalTo(27)
            }
        }
    }
}

// MARK: - Private function
extension CaptureFocusView {
    
    private func startTimer(_ timeInterval: TimeInterval = 2) {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerHideFocus(_:)), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Action
extension CaptureFocusView {
    
    @objc private func timerHideFocus(_ timer: Timer) {
        if self.timer == nil {
            stopTimer()
            return
        }
        if isFocusing {
            if self.alpha == 1 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = self.isAuto ? 0.0 : 0.4
                }) { _ in
                    if self.isAuto {
                        self.isAuto = false
                        self.isFocusing = false
                        self.stopTimer()
                    } else {
                        self.startTimer(8)
                    }
                }
            } else {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 0
                }) { _ in
                    self.isAuto = false
                    self.isFocusing = false
                    self.stopTimer()
                }
            }
        } else {
            stopTimer()
        }
    }
}

// MARK: - CaptureFocusRectView
private final class CaptureFocusRectView: UIView {
    
    private lazy var rectLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 1
        layer.strokeColor = options.theme[color: .focus].cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    private let options: CaptureOptionsInfo
    
    init(frame: CGRect, options: CaptureOptionsInfo) {
        self.options = options
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        layer.addSublayer(rectLayer)
    }
    
    override func draw(_ rect: CGRect) {
        let subLineWidth: CGFloat = 5
        let linePath = UIBezierPath(rect: bounds)
        linePath.move(to: CGPoint(x: 0, y: bounds.height/2))
        linePath.addLine(to: CGPoint(x: subLineWidth, y: bounds.height/2))
        linePath.move(to: CGPoint(x: bounds.width/2, y: 0))
        linePath.addLine(to: CGPoint(x: bounds.width/2, y: subLineWidth))
        linePath.move(to: CGPoint(x: bounds.width, y: bounds.height/2))
        linePath.addLine(to: CGPoint(x: bounds.width-subLineWidth, y: bounds.height/2))
        linePath.move(to: CGPoint(x: bounds.width/2, y: bounds.height))
        linePath.addLine(to: CGPoint(x: bounds.width/2, y: bounds.height-subLineWidth))
        rectLayer.path = linePath.cgPath
    }
}

// MARK: - CaptureExposureView
private final class CaptureExposureView: UIView {
    
    private lazy var imageView: UIImageView = {
        let image = options.theme[icon: .captureSunlight]?.withRenderingMode(.alwaysTemplate)
        let view = UIImageView(image: image)
        view.tintColor = options.theme[color: .focus]
        return view
    }()
    
    private lazy var topLine: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = options.theme[color: .focus]
        return view
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = options.theme[color: .focus]
        return view
    }()
    
    var point: CGPoint = .zero
    var orientation: DeviceOrientation = .portrait
    
    private let options: CaptureOptionsInfo
    private(set) var value: CGFloat = 0.5
    
    init(frame: CGRect, options: CaptureOptionsInfo) {
        self.options = options
        super.init(frame: frame)
        clipsToBounds = true
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(topLine)
        addSubview(bottomLine)
        addSubview(imageView)
        
        imageView.snp.makeConstraints { maker in
            maker.width.height.equalTo(self.snp.width)
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
        topLine.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(-5)
            maker.bottom.equalTo(imageView.snp.top).offset(-3)
            maker.centerX.equalToSuperview()
            maker.width.equalTo(1)
        }
        bottomLine.snp.makeConstraints { maker in
            maker.top.equalTo(imageView.snp.bottom).offset(3)
            maker.bottom.equalToSuperview().offset(5)
            maker.centerX.equalToSuperview()
            maker.width.equalTo(1)
        }
    }
}

extension CaptureExposureView {
    
    func prepare(orientation: DeviceOrientation, animated: Bool, completion: @escaping () -> Void) {
        self.orientation = orientation
        let duration = animated ? 0.15 : 0
        let timingParameters = UICubicTimingParameters(animationCurve: .easeOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        animator.addAnimations {
            self.alpha = 0
        }
        animator.addCompletion { _ in
            self.imageView.snp.removeConstraints()
            self.topLine.snp.removeConstraints()
            self.bottomLine.snp.removeConstraints()
            completion()
        }
        animator.startAnimation()
    }
    
    func rotate(animated: Bool) {
        switch orientation {
        case .portrait, .portraitUpsideDown:
            imageView.snp.remakeConstraints { maker in
                maker.width.height.equalTo(self.snp.width)
                maker.centerX.equalToSuperview()
                maker.centerY.equalToSuperview()
            }
            topLine.snp.remakeConstraints { maker in
                maker.top.equalToSuperview().offset(-5)
                maker.bottom.equalTo(imageView.snp.top).offset(-3)
                maker.centerX.equalToSuperview()
                maker.width.equalTo(1)
            }
            bottomLine.snp.remakeConstraints { maker in
                maker.top.equalTo(imageView.snp.bottom).offset(3)
                maker.bottom.equalToSuperview().offset(5)
                maker.centerX.equalToSuperview()
                maker.width.equalTo(1)
            }
        case .landscapeLeft, .landscapeRight:
            imageView.snp.remakeConstraints { maker in
                maker.height.height.equalTo(self.snp.height)
                maker.centerX.equalToSuperview()
                maker.centerY.equalToSuperview()
            }
            topLine.snp.remakeConstraints { maker in
                maker.left.equalToSuperview().offset(-5)
                maker.right.equalTo(imageView.snp.left).offset(-3)
                maker.centerY.equalToSuperview()
                maker.height.equalTo(1)
            }
            bottomLine.snp.remakeConstraints { maker in
                maker.left.equalTo(imageView.snp.right).offset(3)
                maker.right.equalToSuperview().offset(5)
                maker.centerY.equalToSuperview()
                maker.height.equalTo(1)
            }
        }
        
        layoutIfNeeded()
        setValue(value)
        
        let duration = animated ? 0.15 : 0
        let timingParameters = UICubicTimingParameters(animationCurve: .easeIn)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        animator.addAnimations {
            self.alpha = 1
        }
        animator.startAnimation(afterDelay: 0.1)
    }
    
    func setValue(_ value: CGFloat) {
        guard value >= 0 && value <= 1 else { return }
        self.value = value
        topLine.isHidden = value == 0.5
        bottomLine.isHidden = value == 0.5
        switch orientation {
        case .portrait:
            let height = bounds.height - imageView.bounds.height
            let offset = -(height * 0.5 - height * value)
            imageView.snp.updateConstraints { maker in
                maker.centerX.equalToSuperview()
                maker.centerY.equalToSuperview().offset(offset)
            }
        case .portraitUpsideDown:
            let height = bounds.height - imageView.bounds.height
            let offset = height * 0.5 - height * value
            imageView.snp.updateConstraints { maker in
                maker.centerX.equalToSuperview()
                maker.centerY.equalToSuperview().offset(offset)
            }
        case .landscapeLeft:
            let width = bounds.width - imageView.bounds.width
            let offset = width * 0.5 - width * value
            imageView.snp.updateConstraints { maker in
                maker.centerX.equalToSuperview().offset(offset)
                maker.centerY.equalToSuperview()
            }
        case .landscapeRight:
            let width = bounds.width - imageView.bounds.width
            let offset = -(width * 0.5 - width * value)
            imageView.snp.updateConstraints { maker in
                maker.centerX.equalToSuperview().offset(offset)
                maker.centerY.equalToSuperview()
            }
        }
    }
    
    func resotre() {
        value = 0.5
        topLine.isHidden = true
        bottomLine.isHidden = true
        imageView.snp.updateConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
    }
}
