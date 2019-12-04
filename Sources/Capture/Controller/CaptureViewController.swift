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
    
    
}

final class CaptureViewController: UIViewController {
    
    weak var delegate: CaptureViewControllerDelegate?
    
    private lazy var previewView: CapturePreviewView = {
        let view = CapturePreviewView(frame: .zero)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        capture.connect(to: previewView)
        capture.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        capture.disconnect(from: previewView)
        capture.stopRunning()
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(previewView)
        previewView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.center.equalToSuperview()
            maker.width.equalTo(previewView.snp.height).multipliedBy(9.0/16.0)
        }
    }
}

// MARK: - Target
extension CaptureViewController {
    
    
    
}

// MARK: - CaptureDelegate
extension CaptureViewController: CaptureDelegate {
    
    func captureOutput(audio sampleBuffer: CMSampleBuffer) {
        
    }
    
    func captureOutput(video sampleBuffer: CMSampleBuffer) {
        
    }
}
