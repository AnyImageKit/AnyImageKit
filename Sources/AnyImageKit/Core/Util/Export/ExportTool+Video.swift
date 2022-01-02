//
//  ExportTool+Video.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/29.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos

public struct VideoFetchOptions {
    
    public let isNetworkAccessAllowed: Bool
    public let version: PHVideoRequestOptionsVersion
    public let deliveryMode: PHVideoRequestOptionsDeliveryMode
    public let progressHandler: PHAssetVideoProgressHandler?
    
    public init(isNetworkAccessAllowed: Bool = true,
                version: PHVideoRequestOptionsVersion = .current,
                deliveryMode: PHVideoRequestOptionsDeliveryMode = .highQualityFormat,
                progressHandler: PHAssetVideoProgressHandler? = nil) {
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.version = version
        self.deliveryMode = deliveryMode
        self.progressHandler = progressHandler
    }
}

public struct VideoFetchResponse {
    
    public let playerItem: AVPlayerItem
}

public typealias VideoFetchCompletion = (Result<VideoFetchResponse, AnyImageError>, PHImageRequestID) -> Void
public typealias VideoSaveCompletion = (Result<PHAsset, AnyImageError>) -> Void


extension ExportTool {
    
    @discardableResult
    public static func requestVideo(for asset: PHAsset, options: VideoFetchOptions = .init(), completion: @escaping VideoFetchCompletion) -> PHImageRequestID {
        let requestOptions = PHVideoRequestOptions()
        requestOptions.version = options.version
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.deliveryMode = options.deliveryMode
        requestOptions.progressHandler = options.progressHandler
        
        return PHImageManager.default().requestAVAsset(forVideo: asset, options: requestOptions) { (avAsset, _, info) in
            let requestID = (info?[PHImageResultRequestIDKey] as? PHImageRequestID) ?? 0
            if let avAsset = avAsset {
                completion(.success(.init(playerItem: AVPlayerItem(asset: avAsset))), requestID)
            } else {
                completion(.failure(.invalidVideo), requestID)
            }
        }
    }
    
    public static func saveVideo(_ url: URL, completion: @escaping VideoSaveCompletion) {
        var localIdentifier: String = ""
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier ?? ""
        }) { (isSuccess, error) in
            DispatchQueue.main.async {
                if isSuccess {
                    if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                        completion(.success(asset))
                    } else {
                        completion(.failure(.saveVideoFailed))
                    }
                } else if error != nil {
                    _print("Save video error: \(error!.localizedDescription)")
                    completion(.failure(.saveVideoFailed))
                }
            }
        }
    }
}
