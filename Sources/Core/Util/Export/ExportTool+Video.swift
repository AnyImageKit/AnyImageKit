//
//  ExportTool+Video.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/29.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
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

public typealias VideoFetchCompletion = (Result<VideoFetchResponse, ImageKitError>, PHImageRequestID) -> Void
public typealias VideoSaveCompletion = (Result<PHAsset, ImageKitError>) -> Void


extension ExportTool {
    
    @discardableResult
    public static func requestVideo(for asset: PHAsset, options: VideoFetchOptions = .init(), completion: @escaping VideoFetchCompletion) -> PHImageRequestID {
        let requestOptions = PHVideoRequestOptions()
        requestOptions.version = options.version
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.deliveryMode = options.deliveryMode
        requestOptions.progressHandler = options.progressHandler
        
        return PHImageManager.default().requestPlayerItem(forVideo: asset, options: requestOptions) { (playerItem, info) in
            let requestID = (info?[PHImageResultRequestIDKey] as? PHImageRequestID) ?? 0
            if let playerItem = playerItem {
                completion(.success(.init(playerItem: playerItem)), requestID)
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
                        completion(.failure(.saveVideoFail))
                    }
                } else if error != nil {
                    _print("Save video error: \(error!.localizedDescription)")
                    completion(.failure(.saveVideoFail))
                }
            }
        }
    }
}
