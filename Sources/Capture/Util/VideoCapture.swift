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
    private lazy var photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private lazy var videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
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
            
            // Add photo output, if needed
            setupPhotoOutput(session: session)
            
            // Add video output, if needed
            setupVideoOutput(session: session)
            
        } catch {
            _print(error)
        }
    }
    
    private func setupPhotoOutput(session: AVCaptureSession) {
        guard session.canAddOutput(photoOutput) else {
            _print("Can't add photo output")
            return
        }
        photoOutput.isHighResolutionCaptureEnabled = true
        session.addOutput(photoOutput)
        
        // setup connection
        if let connection = photoOutput.connection(with: .video) {
            print(connection)
            // Set video orientation
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            // Set video stabilization
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .cinematic
            }
        }
    }
    
    private func setupVideoOutput(session: AVCaptureSession) {
        guard session.canAddOutput(videoOutput) else {
            _print("Can't add video output")
            return
        }
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA] as [String : Any]
        videoOutput.setSampleBufferDelegate(self, queue: workQueue)
        session.addOutput(videoOutput)
        
        // setup connection
        if let connection = videoOutput.connection(with: .video) {
            print(connection)
            // Set video orientation
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            // Set video stabilization
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .cinematic
            }
        }
    }
}

// MARK: - Running
extension VideoCapture {
    
    func startRunning() {
        
    }
    
    func stopRunning() {
        
    }
}

// MARK: - Photo
extension VideoCapture {
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput(video: self.videoOutput, didOutput: sampleBuffer)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension VideoCapture: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("willBeginCaptureFor")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("willCapturePhotoFor")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("didCapturePhotoFor")
    }
    
    // for iOS 11+
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("didFinishProcessingPhoto, photo=\(photo)")
    }
    
    // for iOS 10
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        print("didFinishProcessingPhoto, buffer=\(String(describing: photoSampleBuffer))")
    }
}
