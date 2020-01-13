//
//  CaptureFocusView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/1/13.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit

final class CaptureFocusView: UIView {
    
    private(set) var isFocusing: Bool = false
    
    // up = 0, down = 1
    internal var exposureValue: CGFloat {
        return exposureView.value
    }
    
    private lazy var rectView: CaptureFocusRectView = {
        let view = CaptureFocusRectView(frame: .zero, color: color)
        view.isHidden = true
        return view
    }()
    
    private lazy var exposureView: CaptureExposureView = {
        let view = CaptureExposureView(frame: .zero, color: color)
        view.isHidden = true
        return view
    }()
    
    private let color: UIColor
    private var timer: Timer?
    
    init(frame: CGRect, color: UIColor) {
        self.color = color
        super.init(frame: frame)
        setupView()
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(rectView)
        addSubview(exposureView)
        
        rectView.snp.makeConstraints { (maker) in
            maker.top.left.equalToSuperview()
            maker.width.height.equalTo(75)
        }
        exposureView.snp.makeConstraints { (maker) in
            maker.left.equalTo(rectView.snp.right).offset(5)
            maker.centerY.equalTo(rectView)
            maker.width.equalTo(27)
            maker.height.equalTo(145)
        }
    }
}

// MARK: - Public function
extension CaptureFocusView {
    
    public func focusing(at point: CGPoint) {
        stopTimer()
        self.alpha = 0.5
        isFocusing = true
        exposureView.resotre()
        rectView.isHidden = false
        exposureView.isHidden = false
        let offsetX = point.x * bounds.width - rectView.bounds.width / 2
        let offsetY = point.y * bounds.height - rectView.bounds.height / 2
        rectView.snp.updateConstraints { (maker) in
            maker.top.equalToSuperview().offset(offsetY)
            maker.left.equalToSuperview().offset(offsetX)
        }
        exposureView.snp.remakeConstraints { (maker) in
            if point.x < 0.8 {
                maker.left.equalTo(rectView.snp.right).offset(5)
            } else {
                maker.right.equalTo(rectView.snp.left).offset(-5)
            }
            maker.centerY.equalTo(rectView)
            maker.width.equalTo(27)
            maker.height.equalTo(145)
        }
        
        rectView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        exposureView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
            self.rectView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.exposureView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        startTimer()
    }
    
    public func setLight(_ value: CGFloat) {
        stopTimer()
        self.alpha = 1.0
        exposureView.setValue(value)
        startTimer()
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
                    self.alpha = 0.4
                }) { (_) in
                    self.startTimer(8)
                }
            } else {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 0
                }) { (_) in
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
        layer.strokeColor = color.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    private let color: UIColor
    
    init(frame: CGRect, color: UIColor) {
        self.color = color
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
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
        let image = BundleHelper.image(named: "CaptureSunlight")?.withRenderingMode(.alwaysTemplate)
        let view = UIImageView(image: image)
        view.tintColor = color
        return view
    }()
    
    private lazy var topLine: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = color
        return view
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = color
        return view
    }()
    
    private let color: UIColor
    private(set) var value: CGFloat = 0.5
    
    init(frame: CGRect, color: UIColor) {
        self.color = color
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
        
        imageView.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(self.snp.width)
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
        topLine.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(-5)
            maker.bottom.equalTo(imageView.snp.top).offset(-3)
            maker.centerX.equalToSuperview()
            maker.width.equalTo(1)
        }
        bottomLine.snp.makeConstraints { (maker) in
            maker.top.equalTo(imageView.snp.bottom).offset(3)
            maker.bottom.equalToSuperview().offset(5)
            maker.centerX.equalToSuperview()
            maker.width.equalTo(1)
        }
    }
}

extension CaptureExposureView {
    
    public func setValue(_ value: CGFloat) {
        guard value >= 0 && value <= 1 else { return }
        self.value = value
        topLine.isHidden = false
        bottomLine.isHidden = false
        let height = bounds.height - imageView.bounds.height
        let offset = -(height * 0.5 - height * value)
        imageView.snp.updateConstraints { (maker) in
            maker.centerY.equalToSuperview().offset(offset)
        }
    }
    
    public func resotre() {
        value = 0.5
        topLine.isHidden = true
        bottomLine.isHidden = true
        imageView.snp.updateConstraints { (maker) in
            maker.centerY.equalToSuperview()
        }
    }
}
