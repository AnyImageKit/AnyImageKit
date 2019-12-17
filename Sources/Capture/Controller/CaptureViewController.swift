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
    func captureDidOutput(_ capture: CaptureViewController, photo image: UIImage)
}

final class CaptureViewController: UIViewController {
    
    weak var delegate: CaptureViewControllerDelegate?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
        capture.connect(to: previewView)
        capture.startRunning()
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
        
    }
}

// MARK: - CaptureButtonDelegate
extension CaptureViewController: CaptureButtonDelegate {
    
    func captureButtonDidTapped(_ button: CaptureButton) {
        button.startProcessing()
        capture.capturePhoto()
    }
    
    func captureButtonDidBeganLongPress(_ button: CaptureButton) {
        toolView.hideButtons(animated: true)
        previewView.hideMask(animated: true)
        // TODO: start recoder
    }
    
    func captureButtonDidEndedLongPress(_ button: CaptureButton) {
        // TODO: stop recoder
        
        button.startProcessing()
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            button.stopProcessing()
            
            self.toolView.showButtons(animated: true)
            self.previewView.showMask(animated: true)
        }
    }
}

// MARK: - CaptureDelegate
extension CaptureViewController: CaptureDelegate {
    
    func captureOutput(photo image: UIImage) {
        let editor = ImageEditorController(image: image, config: .init(), delegate: self)
        editor.modalPresentationStyle = .fullScreen
        present(editor, animated: false) { [weak self] in
            guard let self = self else { return }
            self.toolView.captureButton.stopProcessing()
            self.capture.stopRunning()
        }
    }
    
    func captureOutput(audio sampleBuffer: CMSampleBuffer) {
        
    }
    
    func captureOutput(video sampleBuffer: CMSampleBuffer) {
        
    }
}

// MARK: - ImageEditorControllerDelegate
extension CaptureViewController: ImageEditorControllerDelegate {
    
    func imageEditorDidCancel(_ editor: ImageEditorController) {
        editor.dismiss(animated: true, completion: nil)
        capture.startRunning()
        capture.connect(to: previewView)
    }
    
    func imageEditor(_ editor: ImageEditorController, didFinishEditing photo: UIImage, isEdited: Bool) {
        print(photo)
        delegate?.captureDidOutput(self, photo: photo)
    }
}
