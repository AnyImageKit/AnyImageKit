//
//  VideoEditorCropToolView.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/19.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

protocol VideoEditorCropToolViewDelegate: AnyObject {
    
    func cropTool(_ view: VideoEditorCropToolView, playButtonTapped button: UIButton)
    func cropTool(_ view: VideoEditorCropToolView, didUpdate progress: CGFloat)
    func cropToolDurationOfVideo(_ view: VideoEditorCropToolView) -> CGFloat
}

final class VideoEditorCropToolView: UIView {
    
    public weak var delegate: VideoEditorCropToolViewDelegate?
    private let options: EditorVideoOptionsInfo
    
    private(set) lazy var playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(options.theme[icon: .videoPlayFill], for: .normal)
        view.setImage(options.theme[icon: .videoPauseFill], for: .selected)
        view.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        view.accessibilityLabel = options.theme[string: .play] + options.theme[string: .pause]
        return view
    }()
    private lazy var splitLine: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.black
        return view
    }()
    private(set) lazy var progressView: VideoEditorCropProgressView = {
        let view = VideoEditorCropProgressView(frame: .zero, options: options)
        view.delegate = self
        return view
    }()
    
    init(frame: CGRect, options: EditorVideoOptionsInfo) {
        self.options = options
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(playButton)
        addSubview(progressView)
        addSubview(splitLine)
        
        playButton.snp.makeConstraints { maker in
            maker.top.left.bottom.equalToSuperview()
            maker.width.equalTo(45)
        }
        splitLine.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.left.equalTo(playButton.snp.right)
            maker.width.equalTo(2)
        }
        progressView.snp.makeConstraints { maker in
            maker.top.right.bottom.equalToSuperview()
            maker.left.equalTo(splitLine.snp.right)
        }
        
        options.theme.buttonConfiguration[.videoPlayPause]?.configuration(playButton)
    }
}

// MARK: - Target
extension VideoEditorCropToolView {
    
    @objc private func playButtonTapped(_ sender: UIButton) {
        delegate?.cropTool(self, playButtonTapped: sender)
    }
}

// MARK: - VideoEditorCropProgressViewDelegate
extension VideoEditorCropToolView: VideoEditorCropProgressViewDelegate {
    
    func cropProgress(_ view: VideoEditorCropProgressView, didUpdate progress: CGFloat) {
        delegate?.cropTool(self, didUpdate: progress)
    }
    
    func cropProgressDurationOfVideo(_ view: VideoEditorCropProgressView) -> CGFloat {
        return delegate?.cropToolDurationOfVideo(self) ?? 0.0
    }
}
