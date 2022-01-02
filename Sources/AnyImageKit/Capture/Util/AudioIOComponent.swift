//
//  AudioIOComponent.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/7/22.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import AVFoundation

protocol AudioIOComponentDelegate: AnyObject {
    
    func audioIO(_ component: AudioIOComponent, didUpdate property: AudioIOComponent.ObservableProperty)
    func audioIO(_ component: AudioIOComponent, didOutput sampleBuffer: CMSampleBuffer)
}

final class AudioIOComponent: DeviceIOComponent {
    
    weak var delegate: AudioIOComponentDelegate?
    
    private let audioOutput = AVCaptureAudioDataOutput()
    private let workQueue = DispatchQueue(label: "org.AnyImageKit.DispatchQueue.AudioCapture")
    
    private let options: CaptureOptionsInfo
    
    init(session: AVCaptureSession, options: CaptureOptionsInfo) {
        self.options = options
        super.init()
        setupMicrophone(session: session)
    }
    
    private func setupMicrophone(session: AVCaptureSession) {
        guard options.mediaOptions.contains(.video) else { return }
        do {
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone],
                                                                    mediaType: .audio,
                                                                    position: .unspecified)
            guard let microphone = discoverySession.devices.first else {
                _print("Can't find the specified audio device")
                return
            }
            self.device = microphone
            let input = try AVCaptureDeviceInput(device: microphone)
            self.input = input
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                _print("Can't add audio device input")
            }
            audioOutput.setSampleBufferDelegate(self, queue: workQueue)
            if session.canAddOutput(audioOutput) {
                session.addOutput(audioOutput)
            } else {
                _print("Can't add audio device output")
            }
        } catch {
            _print(error)
        }
    }
}

// MARK: - Writer Settings
extension AudioIOComponent {
    
    var recommendedWriterSettings: [String: Any]? {
        #if swift(>=5.5)
        return audioOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mp4)
        #else
        return audioOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mp4) as? [String: Any]
        #endif
    }
}

// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate
extension AudioIOComponent: AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.audioIO(self, didOutput: sampleBuffer)
    }
}

extension AudioIOComponent {
    
    enum ObservableProperty: Equatable {
        
    }
}
