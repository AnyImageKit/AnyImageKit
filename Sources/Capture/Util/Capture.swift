//
//  Capture.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/7/22.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import AVFoundation
import UIKit

protocol CaptureDelegate: class {
    
    func capture(_ capture: Capture, didOutput photo: UIImage)
    func capture(_ capture: Capture, didOutput sampleBuffer: CMSampleBuffer, type: Capture.BufferType)
}

final class Capture {
    
    weak var delegate: CaptureDelegate?
    
    private let session: AVCaptureSession
    private let audioCapture: AudioCapture
    private let videoCapture: VideoCapture
    
    private let workQueue = DispatchQueue(label: "org.AnyImageProject.AnyImageKit.DispatchQueue.Capture")
    
    init() {
        session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .photo
        audioCapture = AudioCapture(session: session)
        videoCapture = VideoCapture(session: session)
        session.commitConfiguration()
        audioCapture.delegate = self
        videoCapture.delegate = self
    }
}

// MARK: - Session
extension Capture {
    
    func startRunning() {
        #if !targetEnvironment(simulator)
        workQueue.async {
            self.session.startRunning()
        }
        #endif
    }
    
    func stopRunning() {
        #if !targetEnvironment(simulator)
        workQueue.async {
            self.session.stopRunning()
        }
        #endif
    }
}

// MARK: - Photo
extension Capture {
    
    func capturePhoto() {
        videoCapture.capturePhoto()
    }
}

// MARK: - Video
extension Capture {
    
    func startCaptureVideo() {
        audioCapture.startAudioSession()
    }
    
    func stopCaptureVideo() {
        audioCapture.stopAudioSession()
    }
}

// MARK: - Preview
extension Capture {
    
    func connect(to previewView: CapturePreviewView) {
        previewView.connect(to: session)
    }
    
    func disconnect(from previewView: CapturePreviewView) {
        previewView.disconnect(from: session)
    }
}

// MARK: - AudioCaptureDelegate
extension Capture: AudioCaptureDelegate {
    
    func audioCapture(_ capture: AudioCapture, didOutput sampleBuffer: CMSampleBuffer) {
        delegate?.capture(self, didOutput: sampleBuffer, type: .audio)
    }
}

// MARK: - VideoCaptureDelegate
extension Capture: VideoCaptureDelegate {
    
    func videoCapture(_ capture: VideoCapture, didOutput photo: UIImage) {
        delegate?.capture(self, didOutput: photo)
    }
    
    func videoCapture(_ capture: VideoCapture, didOutput sampleBuffer: CMSampleBuffer) {
        delegate?.capture(self, didOutput: sampleBuffer, type: .video)
    }
}

extension Capture {
    
    enum BufferType {
        case audio
        case video
    }
}
