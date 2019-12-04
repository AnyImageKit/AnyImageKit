//
//  Capture.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/7/22.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import AVFoundation

protocol CaptureDelegate: class {
    
    func captureOutput(audio sampleBuffer: CMSampleBuffer)
    func captureOutput(video sampleBuffer: CMSampleBuffer)
}

final class Capture {
    
    weak var delegate: CaptureDelegate?
    
    private let session: AVCaptureSession
    private let audioCapture: AudioCapture
    private let videoCapture: VideoCapture
    
    init() {
        session = AVCaptureSession()
        audioCapture = AudioCapture(session: session)
        videoCapture = VideoCapture(session: session)
        audioCapture.delegate = self
        videoCapture.delegate = self
    }
}

// MARK: - Session
extension Capture {
    
    func startRunning() {
        #if !targetEnvironment(simulator)
        audioCapture.startRunning()
        videoCapture.startRunning()
        session.startRunning()
        #endif
    }
    
    func stopRunning() {
        #if !targetEnvironment(simulator)
        audioCapture.stopRunning()
        videoCapture.stopRunning()
        session.stopRunning()
        #endif
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
    
    func captureOutput(audio output: AVCaptureAudioDataOutput, didOutput sampleBuffer: CMSampleBuffer) {
        delegate?.captureOutput(audio: sampleBuffer)
    }
}

// MARK: - VideoCaptureDelegate
extension Capture: VideoCaptureDelegate {
    
    func captureOutput(video output: AVCaptureVideoDataOutput, didOutput sampleBuffer: CMSampleBuffer) {
        delegate?.captureOutput(video: sampleBuffer)
    }
}
