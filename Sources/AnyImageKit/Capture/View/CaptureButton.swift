//
//  CaptureButton.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/9.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol CaptureButtonDelegate: AnyObject {
    
    func captureButtonDidTapped(_ button: CaptureButton)
    func captureButtonDidBeganLongPress(_ button: CaptureButton)
    func captureButtonDidEndedLongPress(_ button: CaptureButton)
}

final class CaptureButton: UIControl {
    
    weak var delegate: CaptureButtonDelegate?
    var limitInterval: TimeInterval = 20
    
    private var processState: ProcessState = .idle
    private var startTime = Date()
    private var displayLink: CADisplayLink?
    
    private lazy var circleView: CaptureCircleView = {
        let view = CaptureCircleView(frame: .zero)
        return view
    }()
    
    private lazy var progressView: CaptureProgressView = {
        let view = CaptureProgressView(frame: .zero, options: options)
        return view
    }()
    
    private lazy var buttonView: CaptureRecordView = {
        let view = CaptureRecordView(frame: .zero)
        return view
    }()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 88, height: 88)
    }
    
    private let options: CaptureOptionsInfo
    
    init(frame: CGRect, options: CaptureOptionsInfo) {
        self.options = options
        super.init(frame: frame)
        setupView()
        setupGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(circleView)
        addSubview(progressView)
        addSubview(buttonView)
        circleView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        progressView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        buttonView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.size.equalTo(CGSize(width: 56, height: 56))
        }
    }
    
    private func setupGestureRecognizer() {
        if options.mediaOptions.contains(.photo) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapped(_:)))
            addGestureRecognizer(tapGesture)
        }
        if options.mediaOptions.contains(.video) {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressed(_:)))
            addGestureRecognizer(longPressGesture)
        }
    }
}

// MARK: - Animation
extension CaptureButton {
    
    func startProcessing() {
        guard processState == .idle else { return }
        processState = .processing
        progressView.startProcessing()
    }
    
    func stopProcessing() {
        guard processState == .processing else { return }
        processState = .idle
        progressView.stopProcessing()
    }
}

// MARK: - Target
extension CaptureButton {
    
    @objc private func onTapped(_ sender: UITapGestureRecognizer) {
        guard processState == .idle else { return }
        switch sender.state {
        case .recognized:
            delegate?.captureButtonDidTapped(self)
        default:
            break
        }
    }
     
    @objc private func onLongPressed(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            guard processState == .idle else { return }
            processState = .pressing
            startTime = Date()
            circleView.setStyle(.large, animated: true)
            buttonView.setStyle(.recording, animated: true)
            delegate?.captureButtonDidBeganLongPress(self)
            let displayLink = CADisplayLink(target: self, selector: #selector(onDisplayLink(_:)))
            displayLink.preferredFramesPerSecond = 60
            displayLink.add(to: .current, forMode: .default)
            self.displayLink = displayLink
        case .ended:
            guard processState == .pressing else { return }
            processState = .idle
            progressView.setProgress(0.0)
            circleView.setStyle(.small, animated: true)
            buttonView.setStyle(.normal, animated: true)
            delegate?.captureButtonDidEndedLongPress(self)
        default:
            break
        }
    }
    
    @objc private func onDisplayLink(_ sender: CADisplayLink) {
        switch processState {
        case .pressing:
            let currentTime = Date()
            let timeInterval = currentTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
            if timeInterval >= limitInterval {
                processState = .idle
                progressView.setProgress(0.0)
                circleView.setStyle(.small, animated: true)
                buttonView.setStyle(.normal, animated: true)
                delegate?.captureButtonDidEndedLongPress(self)
                displayLink?.invalidate()
                displayLink = nil
            } else {
                let progress = CGFloat(timeInterval/limitInterval)
                progressView.setProgress(progress)
            }
        default:
            displayLink?.invalidate()
            displayLink = nil
        }
    }
}

extension CaptureButton {
    
    enum ProcessState: Equatable {
        case idle
        case pressing
        case processing
    }
}
