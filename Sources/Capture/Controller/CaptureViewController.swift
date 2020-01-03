//
//  CaptureViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/4.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import AVFoundation

protocol CaptureViewControllerDelegate: class {
    
    func captureDidCancel(_ capture: CaptureViewController)
    func capture(_ capture: CaptureViewController, didOutput media: URL, type: AnyImageMediaType)
}

final class CaptureViewController: UIViewController {
    
    weak var delegate: CaptureViewControllerDelegate?
    
    private var isPreviewing: Bool = true
    
    private lazy var previewView: CapturePreviewView = {
        let view = CapturePreviewView(frame: .zero, options: options)
        return view
    }()
    
    private lazy var toolView: CaptureToolView = {
        let view = CaptureToolView(frame: .zero, options: options)
        view.cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        view.switchButton.addTarget(self, action: #selector(switchButtonTapped(_:)), for: .touchUpInside)
        view.captureButton.delegate = self
        return view
    }()
    
    private lazy var capture: Capture = {
        let capture = Capture(options: options)
        capture.delegate = self
        return capture
    }()
    
    private lazy var recorder: Recorder = {
        let recorder = Recorder()
        recorder.delegate = self
        return recorder
    }()
    
    private lazy var orientationUtil: DeviceOrientationUtil = {
        let util = DeviceOrientationUtil()
        util.delegate = self
        return util
    }()
    
    private let options: AnyImageCaptureOptionsInfo
    
    init(options: AnyImageCaptureOptionsInfo) {
        self.options = options
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
        capture.startRunning()
        orientationUtil.startRunning()
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupView() {
        view.backgroundColor = .black
        let layoutGuide = UILayoutGuide()
        view.addLayoutGuide(layoutGuide)
        view.addSubview(previewView)
        view.addSubview(toolView)
        var aspectRatio: Double = options.photoAspectRatio.value
        if options.mediaOptions.contains(.video) {
            aspectRatio = 9.0/16.0
        }
        previewView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.center.equalToSuperview()
            maker.width.equalTo(previewView.snp.height).multipliedBy(aspectRatio)
        }
        layoutGuide.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.center.equalToSuperview()
            maker.width.equalTo(layoutGuide.snp.height).multipliedBy(9.0/16.0)
        }
        toolView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(layoutGuide.snp.bottom)
            maker.height.equalTo(88)
        }
    }
}

// MARK: - Private
extension CaptureViewController {
    
    private func output(photo: Data, fileType: AnyImageFileType) {
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        let tmpPath = NSTemporaryDirectory()
        let filePath = tmpPath.appending("PHOTO-SAVED-\(timestamp)"+fileType.fileExtension)
        FileHelper.createDirectory(at: tmpPath)
        let url = URL(fileURLWithPath: filePath)
        // Write to file
        do {
            try photo.write(to: url)
            delegate?.capture(self, didOutput: url, type: .photo)
        } catch {
            _print(error.localizedDescription)
        }
    }
    
    private func output(video url: URL) {
        delegate?.capture(self, didOutput: url, type: .video)
    }
}

// MARK: - Target
extension CaptureViewController {
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        delegate?.captureDidCancel(self)
    }
    
    @objc private func switchButtonTapped(_ sender: UIButton) {
        impactFeedback()
        toolView.hideButtons(animated: true)
        previewView.hideToolMask(animated: true)
        previewView.transitionFlip(isIn: sender.isSelected, stopPreview: { [weak self] in
            guard let self = self else { return }
            self.capture.startSwitchCamera()
        }, startPreview: { [weak self] in
            guard let self = self else { return }
            self.capture.stopSwitchCamera()
        }) { [weak self] in
            guard let self = self else { return }
            self.toolView.showButtons(animated: true)
            self.previewView.showToolMask(animated: true)
        }
        sender.isSelected.toggle()
    }
}

// MARK: - Impact Feedback
extension CaptureViewController {
    
    private func impactFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
}

// MARK: - CaptureButtonDelegate
extension CaptureViewController: CaptureButtonDelegate {
    
    func captureButtonDidTapped(_ button: CaptureButton) {
        guard !capture.isSwitchingCamera else { return }
        impactFeedback()
        button.startProcessing()
        capture.capturePhoto()
    }
    
    func captureButtonDidBeganLongPress(_ button: CaptureButton) {
        impactFeedback()
        toolView.hideButtons(animated: true)
        previewView.hideToolMask(animated: true)
        capture.startCaptureVideo()
        recorder.preferredAudioSettings = capture.recommendedAudioSetting
        recorder.preferredVideoSettings = capture.recommendedVideoSetting
        recorder.startRunning()
    }
    
    func captureButtonDidEndedLongPress(_ button: CaptureButton) {
        recorder.stopRunning()
        capture.stopCaptureVideo()
        button.startProcessing()
    }
}

// MARK: - CaptureDelegate
extension CaptureViewController: CaptureDelegate {
    
    func captureWillOutputPhoto(_ capture: Capture) {
        isPreviewing = false
    }
    
    func capture(_ capture: Capture, didOutput photoData: Data, fileType: AnyImageFileType) {
        #if ANYIMAGEKIT_ENABLE_EDITOR
        guard let image = UIImage(data: photoData) else { return }
        let editor = ImageEditorController(image: image, options: .init(), delegate: self)
        editor.modalPresentationStyle = .fullScreen
        present(editor, animated: false) { [weak self] in
            guard let self = self else { return }
            self.toolView.captureButton.stopProcessing()
            self.capture.stopRunning()
            self.orientationUtil.stopRunning()
        }
        #else
        output(photoData: photoData, fileType: fileType)
        #endif
    }
    
    func capture(_ capture: Capture, didOutput sampleBuffer: CMSampleBuffer, type: CaptureBufferType) {
        switch type {
        case .audio:
            recorder.append(sampleBuffer: sampleBuffer, mediaType: .audio)
        case .video:
            recorder.append(sampleBuffer: sampleBuffer, mediaType: .video)
            if isPreviewing {
                previewView.draw(sampleBuffer)
            }
        }
    }
}

// MARK: - RecorderDelegate
extension CaptureViewController: RecorderDelegate {
    
    func recorder(_ recorder: Recorder, didCreateMovieFileAt url: URL, thumbnail: UIImage?) {
        toolView.showButtons(animated: true)
        previewView.showToolMask(animated: true)
        
        #if ANYIMAGEKIT_ENABLE_EDITOR
        let editor = ImageEditorController(video: url, placeholdImage: thumbnail, options: .init(), delegate: self)
        editor.modalPresentationStyle = .fullScreen
        present(editor, animated: false) { [weak self] in
            guard let self = self else { return }
            self.toolView.captureButton.stopProcessing()
            self.capture.stopRunning()
            self.orientationUtil.stopRunning()
        }
        #else
        output(video: url)
        #endif
    }
}

// MARK: - DeviceOrientationUtilDelegate
extension CaptureViewController: DeviceOrientationUtilDelegate {
    
    func device(_ util: DeviceOrientationUtil, didUpdate orientation: CaptureOrientation) {
        capture.orientation = orientation
        recorder.orientation = orientation
        toolView.rotate(to: orientation, animated: true)
    }
}

#if ANYIMAGEKIT_ENABLE_EDITOR

// MARK: - ImageEditorControllerDelegate
extension CaptureViewController: ImageEditorControllerDelegate {
    
    func imageEditorDidCancel(_ editor: ImageEditorController) {
        capture.startRunning()
        orientationUtil.startRunning()
        isPreviewing = true
        editor.dismiss(animated: false, completion: nil)
    }
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing photo: UIImage, isEdited: Bool) {
        guard let photoData = photo.jpegData(compressionQuality: 1.0) else { return }
        output(photo: photoData, fileType: .jpeg)
    }
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing video: URL, isEdited: Bool) {
        output(video: video)
    }
}

#endif
