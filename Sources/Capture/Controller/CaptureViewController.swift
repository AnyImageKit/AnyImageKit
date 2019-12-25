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
    func capture(_ capture: CaptureViewController, didOutput photo: UIImage)
}

final class CaptureViewController: UIViewController {
    
    weak var delegate: CaptureViewControllerDelegate?
    
    private var isPreviewing: Bool = true
    
    private lazy var previewView: CapturePreviewView = {
        let view = CapturePreviewView(frame: .zero)
        return view
    }()
    
    private lazy var toolView: CaptureToolView = {
        let view = CaptureToolView(frame: .zero)
        view.cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        view.switchButton.addTarget(self, action: #selector(switchButtonTapped(_:)), for: .touchUpInside)
        view.captureButton.delegate = self
        return view
    }()
    
    private lazy var capture: Capture = {
        let capture = Capture()
        capture.delegate = self
        return capture
    }()
    
    private lazy var orientationUtil: DeviceOrientationUtil = {
        let util = DeviceOrientationUtil()
        util.delegate = self
        return util
    }()
    
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
        view.addSubview(previewView)
        view.addSubview(toolView)
        previewView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.center.equalToSuperview()
            maker.width.equalTo(previewView.snp.height).multipliedBy(9.0/16.0)
        }
        toolView.snp.makeConstraints { maker in
            maker.left.equalTo(previewView.snp.left)
            maker.right.equalTo(previewView.snp.right)
            maker.bottom.equalTo(previewView.snp.bottom)
            maker.height.equalTo(88)
        }
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
        // TODO: start recoder
    }
    
    func captureButtonDidEndedLongPress(_ button: CaptureButton) {
        // TODO: stop recoder
        
        button.startProcessing()
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            button.stopProcessing()
            
            self.toolView.showButtons(animated: true)
            self.previewView.showToolMask(animated: true)
        }
    }
}

// MARK: - CaptureDelegate
extension CaptureViewController: CaptureDelegate {
    
    func captureWillOutputPhoto(_ capture: Capture) {
        isPreviewing = false
    }
    
    func capture(_ capture: Capture, didOutput photoData: Data) {
        guard let photo = UIImage(data: photoData) else { return }
        let editor = ImageEditorController(image: photo, config: .init(), delegate: self)
        editor.modalPresentationStyle = .fullScreen
        present(editor, animated: false) { [weak self] in
            guard let self = self else { return }
            self.toolView.captureButton.stopProcessing()
            self.capture.stopRunning()
            self.orientationUtil.stopRunning()
        }
    }
    
    func capture(_ capture: Capture, didOutput sampleBuffer: CMSampleBuffer, type: CaptureBufferType) {
        switch type {
        case .audio:
            break
        case .video:
            if isPreviewing {
                previewView.draw(sampleBuffer)
            }
        }
    }
}

// MARK: - DeviceOrientationUtilDelegate
extension CaptureViewController: DeviceOrientationUtilDelegate {
    
    func device(_ util: DeviceOrientationUtil, didUpdate orientation: CaptureOrientation) {
        capture.orientation = orientation
        toolView.rotate(to: orientation, animated: true)
    }
}

// MARK: - ImageEditorControllerDelegate
extension CaptureViewController: ImageEditorControllerDelegate {
    
    func imageEditorDidCancel(_ editor: ImageEditorController) {
        capture.startRunning()
        orientationUtil.startRunning()
        isPreviewing = true
        editor.dismiss(animated: false, completion: nil)
    }
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing photo: UIImage, isEdited: Bool) {
        delegate?.capture(self, didOutput: photo)
    }
}
