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
    
    func captureOutput(photo image: UIImage)
    func captureOutput(audio sampleBuffer: CMSampleBuffer)
    func captureOutput(video sampleBuffer: CMSampleBuffer)
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
            self.audioCapture.startRunning()
            self.videoCapture.startRunning()
            self.session.startRunning()
        }
        #endif
    }
    
    func stopRunning() {
        #if !targetEnvironment(simulator)
        workQueue.async {
            self.session.stopRunning()
            self.audioCapture.stopRunning()
            self.videoCapture.stopRunning()
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
        
    }
    
    func stopCaptureVideo() {
        
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
    
    func captureOutput(photo image: UIImage) {
        delegate?.captureOutput(photo: image)
    }
    
    func captureOutput(video output: AVCaptureVideoDataOutput, didOutput sampleBuffer: CMSampleBuffer) {
        delegate?.captureOutput(video: sampleBuffer)
    }
}
