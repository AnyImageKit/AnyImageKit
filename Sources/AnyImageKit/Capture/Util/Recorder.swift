//
//  Recorder.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/7/22.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import AVFoundation
import UIKit

protocol RecorderDelegate: AnyObject {
    
    func recorder(_ recorder: Recorder, didCreateMovieFileAt url: URL, thumbnail: UIImage?)
}

final class Recorder {
    
    weak var delegate: RecorderDelegate?
    
    var preferredAudioSettings: [String: Any]?
    var preferredVideoSettings: [String: Any]?
    
    var orientation: DeviceOrientation = .portrait
    
    private(set) var isRunning: Bool = false
    
    private let workQueue = DispatchQueue(label: "org.AnyImageKit.DispatchQueue.Recorder")
    
    private var writer: AVAssetWriter?
    private var writerInputs: [AVMediaType: AVAssetWriterInput] = [:]
}

extension Recorder {
    
    var isReadyForStartWriting: Bool {
        guard let writer: AVAssetWriter = writer else { return false }
        return writer.inputs.count == 2
    }
    
    func append(sampleBuffer: CMSampleBuffer, mediaType: AVMediaType) {
        workQueue.async {
            guard self.isRunning else { return }
            
            if self.writer == nil, mediaType == .video {
                self.writer = self.createWriter()
            }
            
            guard let writer = self.writer else {
                return
            }
            
            let input = self.getWriterInput(for: mediaType, format: sampleBuffer.formatDescription)
            
            guard self.isReadyForStartWriting else { return }
            
            switch writer.status {
            case .unknown:
                if mediaType == .video {
                    writer.startWriting()
                    writer.startSession(atSourceTime: sampleBuffer.presentationTimeStamp)
                }
            default:
                break
            }
            
            if input.isReadyForMoreMediaData {
                input.append(sampleBuffer)
            }
        }
    }
}

extension Recorder {
    
    func startRunning() {
        workQueue.async {
            guard !self.isRunning else { return }
            self.isRunning = true
        }
    }
    
    func stopRunning() {
        workQueue.async {
            guard self.isRunning else { return }
            self.finishWriting()
            self.isRunning = false
        }
    }
}

extension Recorder {
    
    private func finishWriting() {
        guard let writer: AVAssetWriter = writer, writer.status == .writing else {
            return
        }
        for (_, input) in writerInputs {
            input.markAsFinished()
        }
        
        writer.finishWriting { [weak self] in
            guard let self = self else { return }
            self.writer = nil
            self.writerInputs.removeAll()
            
            let outputURL = writer.outputURL
            let thumbnail = self.createThumbnail(at: outputURL)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.recorder(self, didCreateMovieFileAt: outputURL, thumbnail: thumbnail)
            }
        }
    }
    
    private func getWriterInput(for mediaType: AVMediaType, format: CMFormatDescription?) -> AVAssetWriterInput {
        if let writerInput = writerInputs[mediaType] {
            return writerInput
        } else {
            var outputSettings: [String: Any]? = nil
            switch mediaType {
            case .audio:
                outputSettings = preferredAudioSettings
            case .video:
                outputSettings = preferredVideoSettings
            default:
                break
            }
            let input = AVAssetWriterInput(mediaType: mediaType, outputSettings: outputSettings, sourceFormatHint: format)
            input.expectsMediaDataInRealTime = true
            input.transform = orientation.transform
            if let writer = writer, writer.canAdd(input) {
                writerInputs[mediaType] = input
                writer.add(input)
            }
            return input
        }
    }
    
    private func createWriter() -> AVAssetWriter? {
        do {
            let outputURL = FileHelper.getTemporaryUrl(by: .video, fileType: .mp4)
            _print("Create AVAssetWriter at utl: \(outputURL)")
            return try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        } catch {
            _print("Fail to create AVAssetWriter, error=\(error)")
        }
        return nil
    }
    
    private func createThumbnail(at url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0.0, preferredTimescale: 1_000_000_000)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            _print("Fail to create Thumbnail at url = \(url), error = \(error)")
        }
        return nil
    }
}
