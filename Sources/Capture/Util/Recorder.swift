//
//  Recorder.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/7/22.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import AVFoundation
import UIKit

protocol RecorderDelegate: class {
    
    func recorder(_ recorder: Recorder, didCreateMovieFileAt url: URL, thumbnail: UIImage?)
}

final class Recorder {
    
    weak var delegate: RecorderDelegate?
    
    var preferredFileName: String?
    var preferredAudioSettings: [String: Any]?
    var preferredVideoSettings: [String: Any]?
    
    private(set) var isRunning: Bool = false
    
    private let cacheTool = CacheTool(config: .init(module: .capture(.recorder)))
    private let workQueue = DispatchQueue(label: "org.AnyImageProject.AnyImageKit.DispatchQueue.Recorder")
    
    private var writer: AVAssetWriter?
    private var writerInputs: [AVMediaType: AVAssetWriterInput] = [:]
    
    private var sourceTime: CMTime = .zero
    private var duration: Int64 = 0
    private var rotateTime: CMTime = .zero
    private var clockReference: AVMediaType = .video
}

extension Recorder {
    
    var isReadyForStartWriting: Bool {
        guard let writer: AVAssetWriter = writer else {
            return false
        }
        return writer.inputs.count == 2
    }
    
    func append(sampleBuffer: CMSampleBuffer, mediaType: AVMediaType) {
        workQueue.async {
            guard self.isRunning else { return }
            
            self.rotateFile(with: sampleBuffer.presentationTimeStamp, mediaType: mediaType)
            
            guard let writer = self.writer, let input = self.getWriterInput(mediaType: mediaType, sourceFormatHint: sampleBuffer.formatDescription), self.isReadyForStartWriting else {
                return
            }
            
            switch writer.status {
            case .unknown:
                writer.startWriting()
                writer.startSession(atSourceTime: self.sourceTime)
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
        writer.finishWriting {
            self.writer = nil
            self.writerInputs.removeAll()
        }
        
        let outputURL = writer.outputURL
        let thumbnail = createThumbnail(at: outputURL)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.recorder(self, didCreateMovieFileAt: outputURL, thumbnail: thumbnail)
        }
    }
    
    private func rotateFile(with presentationTimeStamp: CMTime, mediaType: AVMediaType) {
        guard clockReference == mediaType && rotateTime.value < presentationTimeStamp.value else {
            return
        }
        if writer != nil {
            finishWriting()
        }
        writer = createWriter(preferredFileName)
        rotateTime = CMTimeAdd(
            presentationTimeStamp,
            CMTimeMake(value: duration == 0 ? .max : duration * Int64(presentationTimeStamp.timescale), timescale: presentationTimeStamp.timescale)
        )
        sourceTime = presentationTimeStamp
    }
    
    private func getWriterInput(mediaType: AVMediaType, sourceFormatHint: CMFormatDescription?) -> AVAssetWriterInput? {
        if let writerInput = writerInputs[mediaType] {
            return writerInput
        } else {
            var outputSettings: [String: Any]?
            switch mediaType {
            case .audio:
                outputSettings = preferredAudioSettings
            case .video:
                outputSettings = preferredVideoSettings
            default:
                break
            }
            let writerInput = AVAssetWriterInput(mediaType: mediaType, outputSettings: outputSettings, sourceFormatHint: sourceFormatHint)
            writerInput.expectsMediaDataInRealTime = true
            writerInputs[mediaType] = writerInput
            writer?.add(writerInput)
            return writerInput
        }
    }
    
    private func createWriter(_ fileName: String?) -> AVAssetWriter? {
        do {
            FileHelper.createDirectory(at: cacheTool.path)
            let pathURL = URL(fileURLWithPath: cacheTool.path)
            let url = pathURL.appendingPathComponent((fileName ?? UUID().uuidString) + ".mp4")
            _print("Create AVAssetWriter at utl: \(url)")
            return try AVAssetWriter(outputURL: url, fileType: .mp4)
        } catch {
            _print("Fail to create AVAssetWriter, error=\(error)")
        }
        return nil
    }
    
    private func createThumbnail(at url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0.1, preferredTimescale: 1000_000_000)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            _print("Fail to create Thumbnail at url = \(url), error = \(error)")
        }
        return nil
    }
}
