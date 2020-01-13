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
    
    func captureDidCapturePhoto(_ capture: Capture)
    func capture(_ capture: Capture, didOutput photoData: Data, fileType: FileType)
    func capture(_ capture: Capture, didOutput sampleBuffer: CMSampleBuffer, type: CaptureBufferType)
}

final class Capture {
    
    weak var delegate: CaptureDelegate?
    
    private let options: CaptureParsedOptionsInfo
    private let session: AVCaptureSession
    private let audioIO: AudioIOComponent
    private let videoIO: VideoIOComponent
    
    private var exposureBiasBaseline: Float = 0
    
    var orientation: DeviceOrientation = .portrait
    var isSwitchingCamera = false
    
    init(options: CaptureParsedOptionsInfo) {
        self.options = options
        self.session = AVCaptureSession()
        self.session.beginConfiguration()
        self.audioIO = AudioIOComponent(session: session, options: options)
        self.videoIO = VideoIOComponent(session: session, options: options)
        self.session.commitConfiguration()
        self.audioIO.delegate = self
        self.videoIO.delegate = self
    }
}

// MARK: - Session
extension Capture {
    
    func startRunning() {
        #if !targetEnvironment(simulator)
        DispatchQueue.global().async {
            self.session.startRunning()
        }
        #endif
    }
    
    func stopRunning() {
        #if !targetEnvironment(simulator)
        DispatchQueue.global().async {
            self.session.stopRunning()
        }
        #endif
    }
}

// MARK: - Camera
extension Capture {
    
    func startSwitchCamera() {
        isSwitchingCamera = true
        session.beginConfiguration()
        videoIO.switchCamera(session: session)
        session.commitConfiguration()
    }
    
    func stopSwitchCamera() -> CapturePosition {
        isSwitchingCamera = false
        return videoIO.position
    }
    
    func focus(at point: CGPoint) {
        videoIO.setFocus(point: point)
    }
    
    func exposure(at point: CGPoint) {
        videoIO.setExposure(point: point)
    }
    
    func beginUpdateExposureTargetBias() {
        exposureBiasBaseline = videoIO.exposureTargetBias
    }

    func endUpdateExposureTargetBias() {
        exposureBiasBaseline = 0
    }
    
    func exposure(bias level: Float) {
        let base = exposureBiasBaseline
        let avaiableRange: Float = 0.4
        if level < 0.5 { // [minExposureTargetBias, exposureBiasBaseline)
            let systemMin = videoIO.minExposureTargetBias
            let min = systemMin + (base-systemMin)*avaiableRange
            let newBias = min + (base-min)*(level/0.5)
            videoIO.setExposure(bias: newBias)
        } else { // [exposureBiasBaseline, maxExposureTargetBias]
            let systemMax = videoIO.maxExposureTargetBias
            let max = base + (systemMax-base)*avaiableRange
            let newBias = base + (max - base)*((level-0.5)/0.5)
            videoIO.setExposure(bias: newBias)
        }
    }
}

// MARK: - Photo
extension Capture {
    
    func capturePhoto() {
        videoIO.capturePhoto(orientation: orientation)
    }
}

// MARK: - Asset Writer Settings
extension Capture {
    
    var recommendedAudioSetting: [String: Any]? {
        return audioIO.recommendedWriterSettings
    }
    
    var recommendedVideoSetting: [String: Any]? {
        return videoIO.recommendedWriterSettings
    }
}

// MARK: - AudioIOComponentDelegate
extension Capture: AudioIOComponentDelegate {
    
    func audioIO(_ component: AudioIOComponent, didOutput sampleBuffer: CMSampleBuffer) {
        delegate?.capture(self, didOutput: sampleBuffer, type: .audio)
    }
}

// MARK: - VideoIOComponentDelegate
extension Capture: VideoIOComponentDelegate {
    
    func videoIODidCapturePhoto(_ component: VideoIOComponent) {
        delegate?.captureDidCapturePhoto(self)
    }
    
    func videoIO(_ component: VideoIOComponent, didOutput photoData: Data, fileType: FileType) {
        delegate?.capture(self, didOutput: photoData, fileType: fileType)
    }
    
    func videoIO(_ component: VideoIOComponent, didOutput sampleBuffer: CMSampleBuffer) {
        guard !isSwitchingCamera else { return }
        delegate?.capture(self, didOutput: sampleBuffer, type: .video)
    }
}
