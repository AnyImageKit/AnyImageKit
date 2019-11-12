//
//  PhotoManager+Video.swift
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

public typealias VideoFetchCompletion = (Result<VideoFetchResponse, ImagePickerError>) -> Void
typealias VideoSaveCompletion = (Result<PHAsset, ImagePickerError>) -> Void

extension PhotoManager {
    
    func requestVideo(for asset: PHAsset, options: VideoFetchOptions = .init(), completion: @escaping VideoFetchCompletion) {
        let requestOptions = PHVideoRequestOptions()
        requestOptions.version = options.version
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.deliveryMode = options.deliveryMode
        requestOptions.progressHandler = options.progressHandler
        
        let requestID = PHImageManager.default().requestPlayerItem(forVideo: asset, options: requestOptions) { [weak self] (playerItem, info) in
            guard let self = self else { return }
            if let playerItem = playerItem {
                completion(.success(.init(playerItem: playerItem)))
            } else {
                completion(.failure(.invalidVideo))
            }
            let requestID = info?[PHImageResultRequestIDKey] as? PHImageRequestID
            self.dequeueFetch(for: asset.localIdentifier, requestID: requestID)
        }
        enqueueFetch(for: asset.localIdentifier, requestID: requestID)
    }
    
    func saveVideo(at url: URL, completion: @escaping VideoSaveCompletion) {
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
