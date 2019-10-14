//
//  PhotoManager+Video.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/29.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos

struct VideoFetchOptions {
    
    let isNetworkAccessAllowed: Bool
    let version: PHVideoRequestOptionsVersion
    let deliveryMode: PHVideoRequestOptionsDeliveryMode
    let progressHandler: PHAssetVideoProgressHandler?
    
    init(isNetworkAccessAllowed: Bool = true,
         version: PHVideoRequestOptionsVersion = .current,
         deliveryMode: PHVideoRequestOptionsDeliveryMode = .fastFormat,
         progressHandler: PHAssetVideoProgressHandler? = nil) {
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.version = version
        self.deliveryMode = deliveryMode
        self.progressHandler = progressHandler
    }
}

typealias VideoFetchResponse = AVPlayerItem
typealias VideoFetchCompletion = (Result<VideoFetchResponse, ImagePickerError>) -> Void

extension PhotoManager {
    
    func requestVideo(for asset: PHAsset, options: VideoFetchOptions = .init(), completion: @escaping VideoFetchCompletion) {
        let requestOptions = PHVideoRequestOptions()
        requestOptions.version = options.version
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.deliveryMode = options.deliveryMode
        requestOptions.progressHandler = options.progressHandler
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: requestOptions) { (playerItem, info) in
            if let playerItem = playerItem {
                completion(.success(playerItem))
            } else {
                completion(.failure(.invalidVideo))
            }
        }
    }
}
