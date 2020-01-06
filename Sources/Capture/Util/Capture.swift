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
    
    func captureWillOutputPhoto(_ capture: Capture)
    func capture(_ capture: Capture, didOutput photoData: Data, fileType: AnyImageFileType)
    func capture(_ capture: Capture, didOutput sampleBuffer: CMSampleBuffer, type: CaptureBufferType)
}

final class Capture {
    
    weak var delegate: CaptureDelegate?
    
    private let options: AnyImageCaptureOptionsInfo
    private let session: AVCaptureSession
    private let audioCapture: AudioCapture
    private let videoCapture: VideoCapture
    
    var orientation: DeviceOrientation = .portrait
    var isSwitchingCamera = false
    
    init(options: AnyImageCaptureOptionsInfo) {
        self.options = options
        self.session = AVCaptureSession()
        self.session.beginConfiguration()
        self.audioCapture = AudioCapture(session: session, options: options)
        self.videoCapture = VideoCapture(session: session, options: options)
        self.session.commitConfiguration()
        self.audioCapture.delegate = self
        self.videoCapture.delegate = self
    }
}

// MARK: - Session
extension Capture {
    
    func startRunning() {
        #if !targetEnvironment(simulator)
        session.startRunning()
        #endif
    }
    
    func stopRunning() {
        #if !targetEnvironment(simulator)
        session.stopRunning()
        #endif
    }
}

// MARK: - Camera
extension Capture {
    
    func startSwitchCamera() {
        isSwitchingCamera = true
        session.beginConfiguration()
        videoCapture.switchCamera(session: session)
        session.commitConfiguration()
    }
    
    func stopSwitchCamera() {
        isSwitchingCamera = false
    }
}

// MARK: - Photo
extension Capture {
    
    func capturePhoto() {
        videoCapture.capturePhoto(orientation: orientation)
    }
}

// MARK: - Video
extension Capture {
    
    func startCaptureVideo() {
        audioCapture.startAudioSession()
        audioCapture.addMicrophone(session: session)
    }
    
    func stopCaptureVideo() {
        audioCapture.removeMicrophone(session: session)
        audioCapture.stopAudioSession()
    }
}

// MARK: - Asset Writer Settings
extension Capture {
    
    var recommendedAudioSetting: [String: Any]? {
        return audioCapture.recommendedWriterSettings
    }
    
    var recommendedVideoSetting: [String: Any]? {
        return videoCapture.recommendedWriterSettings
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
    
    func videoCaptureWillOutputPhoto(_ capture: VideoCapture) {
        delegate?.captureWillOutputPhoto(self)
    }
    
    func videoCapture(_ capture: VideoCapture, didOutput photoData: Data, fileType: AnyImageFileType) {
        delegate?.capture(self, didOutput: photoData, fileType: fileType)
    }
    
    func videoCapture(_ capture: VideoCapture, didOutput sampleBuffer: CMSampleBuffer) {
        guard !isSwitchingCamera else { return }
        delegate?.capture(self, didOutput: sampleBuffer, type: .video)
    }
}

