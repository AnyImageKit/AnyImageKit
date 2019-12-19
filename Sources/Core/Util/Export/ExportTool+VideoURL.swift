//
//  ExportTool+VideoURL.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/29.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Photos
import AVFoundation

public enum VideoPreset: RawRepresentable, Equatable {
    /// H.264/AVC 640x480
    case h264_640x480
    /// H.264/AVC 960x540
    case h264_960x540
    /// H.264/AVC 1280x720
    case h264_1280x720
    /// H.264/AVC 1920x1080
    case h264_1920x1080
    /// H.264/AVC 3840x2160
    case h264_3840x2160
    
    /// H.265/HEVC 1920x1080
    @available(iOS 11.0, *)
    case h265_1920x1080
    /// H.265/HEVC 3840x2160
    @available(iOS 11.0, *)
    case h265_3840x2160
    
    public var rawValue: String {
        switch self {
        case .h264_640x480:
            return AVAssetExportPreset640x480
        case .h264_960x540:
            return AVAssetExportPreset960x540
        case .h264_1280x720:
            return AVAssetExportPreset1280x720
        case .h264_1920x1080:
            return AVAssetExportPreset1920x1080
        case .h264_3840x2160:
            return AVAssetExportPreset3840x2160
        case .h265_1920x1080:
            if #available(iOS 11.0, *) {
                return AVAssetExportPresetHEVC1920x1080
            } else {
                return AVAssetExportPreset1920x1080
            }
        case .h265_3840x2160:
            if #available(iOS 11.0, *) {
                return AVAssetExportPresetHEVC3840x2160
            } else {
                return AVAssetExportPreset3840x2160
            }
        }
    }
    
    public init?(rawValue: String) {
        if #available(iOS 11.0, *) {
            switch rawValue {
            case AVAssetExportPreset640x480:
                self = .h264_640x480
            case AVAssetExportPreset960x540:
                self = .h264_960x540
            case AVAssetExportPreset1280x720:
                self = .h264_1280x720
            case AVAssetExportPreset1920x1080:
                self = .h264_1920x1080
            case AVAssetExportPreset3840x2160:
                self = .h264_3840x2160
            case AVAssetExportPresetHEVC1920x1080:
                self = .h265_1920x1080
            case AVAssetExportPresetHEVC3840x2160:
                self = .h265_3840x2160
            default:
                return nil
            }
        } else {
            switch rawValue {
            case AVAssetExportPreset640x480:
                self = .h264_640x480
            case AVAssetExportPreset960x540:
                self = .h264_960x540
            case AVAssetExportPreset1280x720:
                self = .h264_1280x720
            case AVAssetExportPreset1920x1080:
                self = .h264_1920x1080
            case AVAssetExportPreset3840x2160:
                self = .h264_3840x2160
            default:
                return nil
            }
        }
    }
}

public typealias VideoURLExportProgressHandler = (Double) -> Void

public struct VideoURLFetchOptions {
    
    public let isNetworkAccessAllowed: Bool
    public let version: PHVideoRequestOptionsVersion
    public let deliveryMode: PHVideoRequestOptionsDeliveryMode
    public let fetchProgressHandler: PHAssetVideoProgressHandler?
    public let preferredOutputPath: String
    public let exportPreset: VideoPreset
    public let exportProgressHandler: VideoURLExportProgressHandler?
    
    public init(isNetworkAccessAllowed: Bool = true,
                version: PHVideoRequestOptionsVersion = .current,
                deliveryMode: PHVideoRequestOptionsDeliveryMode = .automatic,
                fetchProgressHandler: PHAssetVideoProgressHandler? = nil,
                preferredOutputPath: String = NSTemporaryDirectory(),
                exportPreset: VideoPreset = .h264_1280x720,
                exportProgressHandler: VideoURLExportProgressHandler? = nil) {
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.version = version
        self.deliveryMode = deliveryMode
        self.fetchProgressHandler = fetchProgressHandler
        self.preferredOutputPath = preferredOutputPath
        self.exportPreset = exportPreset
        self.exportProgressHandler = exportProgressHandler
    }
}

public struct VideoURLFetchResponse {
    
    public let url: URL
}

public typealias VideoURLFetchCompletion = (Result<VideoURLFetchResponse, ImageKitError>, PHImageRequestID) -> Void


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
    
    private static  func exportVideoData(for exportSession: AVAssetExportSession, options: VideoURLFetchOptions, completion: @escaping (Result<VideoURLFetchResponse, ImageKitError>) -> Void) {
        // Check Path
        FileHelper.createDirectory(at: options.preferredOutputPath)
        // Check File Type
        let supportedFileTypes = exportSession.supportedFileTypes
        guard supportedFileTypes.contains(.mp4) else {
            completion(.failure(.unsupportedFileType))
            return
        }
        // Prepare Output URL
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        let outputPath = options.preferredOutputPath.appending("VIDEO-EXPORT-\(timestamp).mp4")
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
                    completion(.failure(.exportFail))
                case .cancelled:
                    completion(.failure(.exportCancel))
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
