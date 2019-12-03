//
//  VideoCapture.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/7/22.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import AVFoundation

protocol VideoCaptureDelegate: class {
    
    func captureOutput(video output: AVCaptureVideoDataOutput, didOutput sampleBuffer: CMSampleBuffer)
}

final class VideoCapture: NSObject {
    
    weak var delegate: VideoCaptureDelegate?
    
    private var device: AVCaptureDevice?
    private var input: AVCaptureDeviceInput?
    private var output: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    private let workQueue = DispatchQueue(label: "org.AnyImageProject.AnyImageKit.DispatchQueue.VideoCapture")
    
    init(session: AVCaptureSession) {
        super.init()
        do {
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                    mediaType: .video,
                                                                    position: .back)
            guard let camera = discoverySession.devices.first else {
                _print("Can't find the specified video device")
                return
            }
            self.device = camera
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
                self.input = input
            } else {
                _print("Can't add video device input")
            }
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA] as [String : Any]
            output.setSampleBufferDelegate(self, queue: workQueue)
            if session.canAddOutput(output) {
                session.addOutput(output)
            } else {
                _print("Can't add video device output")
            }
            if let connection = output.connection(with: .video) {
                // Set video orientation
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
                // Set video stabilization
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .cinematic
                }
            }
        } catch {
            _print(error)
        }
    }
    
    func startRunning() {
        
    }
    
    func stopRunning() {
        
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput(video: self.output, didOutput: sampleBuffer)
    }
}
