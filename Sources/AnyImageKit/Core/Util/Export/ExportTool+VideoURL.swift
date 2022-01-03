//
//  ExportTool+VideoURL.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/29.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos
import AVFoundation

public typealias VideoURLExportProgressHandler = (Double) -> Void

public struct VideoURLFetchOptions {
    
    public let isNetworkAccessAllowed: Bool
    public let version: PHVideoRequestOptionsVersion
    public let deliveryMode: PHVideoRequestOptionsDeliveryMode
    public let fetchProgressHandler: PHAssetVideoProgressHandler?
    public let preferredOutputPath: String
    public let exportPreset: VideoExportPreset
    public let exportProgressHandler: VideoURLExportProgressHandler?
    
    public init(isNetworkAccessAllowed: Bool = true,
                version: PHVideoRequestOptionsVersion = .current,
                deliveryMode: PHVideoRequestOptionsDeliveryMode = .highQualityFormat,
                fetchProgressHandler: PHAssetVideoProgressHandler? = nil,
                preferredOutputPath: String? = nil,
                exportPreset: VideoExportPreset = .h264_1280x720,
                exportProgressHandler: VideoURLExportProgressHandler? = nil) {
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.version = version
        self.deliveryMode = deliveryMode
        self.fetchProgressHandler = fetchProgressHandler
        if let preferredOutputPath = preferredOutputPath {
            self.preferredOutputPath = preferredOutputPath
        } else {
            self.preferredOutputPath = FileHelper.temporaryDirectory(for: .video)
        }
        self.exportPreset = exportPreset
        self.exportProgressHandler = exportProgressHandler
    }
}

public struct VideoURLFetchResponse {
    
    public let url: URL
}

public typealias VideoURLFetchCompletion = (Result<VideoURLFetchResponse, AnyImageError>, PHImageRequestID) -> Void


extension ExportTool {
    
    @discardableResult
    public static func requestVideoURL(for asset: PHAsset, options: VideoURLFetchOptions = .init(), completion: @escaping VideoURLFetchCompletion) -> PHImageRequestID {
        let supportPresets = AVAssetExportSession.allExportPresets()
        guard supportPresets.contains(options.exportPreset.rawValue) else {
            completion(.failure(.invalidExportPreset), 0)
            return 0
        }
        
        let requestOptions = PHVideoRequestOptions()
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.version = options.version
        requestOptions.deliveryMode = options.deliveryMode
        requestOptions.progressHandler = options.fetchProgressHandler
        
        return PHImageManager.default().requestExportSession(forVideo: asset, options: requestOptions, exportPreset: options.exportPreset.rawValue) { (exportSession, info) in
            let requestID = (info?[PHImageResultRequestIDKey] as? PHImageRequestID) ?? 0
            if let exportSession = exportSession {
                ExportTool.exportVideoData(for: exportSession, options: options) { (result) in
                    switch result {
                    case .success(let response):
                        completion(.success(response), requestID)
                    case .failure(let error):
                        completion(.failure(error), requestID)
                    }
                }
            } else {
                completion(.failure(.invalidExportSession), requestID)
            }
        }
    }
    
    private static  func exportVideoData(for exportSession: AVAssetExportSession, options: VideoURLFetchOptions, completion: @escaping (Result<VideoURLFetchResponse, AnyImageError>) -> Void) {
        // Check Path
        FileHelper.createDirectory(at: options.preferredOutputPath)
        // Check File Type
        let supportedFileTypes = exportSession.supportedFileTypes
        guard supportedFileTypes.contains(.mp4) else {
            completion(.failure(.unsupportedFileType))
            return
        }
        // Prepare Output URL
        let dateString = FileHelper.dateString()
        let outputPath = options.preferredOutputPath.appending("VIDEO-\(dateString).mp4")
        let outputURL = URL(fileURLWithPath: outputPath)
        // Setup Export Session
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.outputFileType = .mp4
        exportSession.outputURL = outputURL
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .unknown:
                    break
                case .waiting:
                    break
                case .exporting:
                    break
                case .completed:
                    completion(.success(VideoURLFetchResponse(url: outputURL)))
                case .failed:
                    completion(.failure(.exportFailed))
                case .cancelled:
                    completion(.failure(.exportCanceled))
                @unknown default:
                    break
                }
            }
        }
        // Setup Export Progress
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                switch exportSession.status {
                case .unknown, .waiting, .exporting:
                    options.exportProgressHandler?(Double(exportSession.progress))
                case .completed, .failed, .cancelled:
                    timer.invalidate()
                @unknown default:
                    break
                }
            }
        }
    }
}
