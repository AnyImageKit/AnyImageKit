//
//  PickerManager+LivePhoto.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/22.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

@available(iOS 9.1, *)
struct LivePhotoFetchOptions {

    let targetSize: CGSize
    let version: PHImageRequestOptionsVersion
    let deliveryMode: PHImageRequestOptionsDeliveryMode
    let isNetworkAccessAllowed: Bool
    let progressHandler: PHAssetImageProgressHandler?
    
    init(targetSize: CGSize = .init(width: 500, height: 500),
         version: PHImageRequestOptionsVersion = .current,
         deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat,
         isNetworkAccessAllowed: Bool = true,
         progressHandler: PHAssetImageProgressHandler? = nil) {
        self.targetSize = targetSize
        self.version = version
        self.deliveryMode = deliveryMode
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
    }
}

@available(iOS 9.1, *)
struct LivePhotoFetchResponse {
    let livePhoto: PHLivePhoto
}

@available(iOS 9.1, *)
typealias LivePhotoFetchCompletion = (Result<LivePhotoFetchResponse, ImagePickerError>) -> Void

extension PickerManager {
    
    @available(iOS 9.1, *)
    func requestLivePhoto(for asset: PHAsset, options: LivePhotoFetchOptions = .init(), completion: @escaping LivePhotoFetchCompletion) {
        let requestOptions = PHLivePhotoRequestOptions()
        requestOptions.version = options.version
        requestOptions.deliveryMode = options.deliveryMode
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.progressHandler = options.progressHandler
        
        let requestID = PHImageManager.default().requestLivePhoto(for: asset, targetSize: options.targetSize, contentMode: .aspectFill, options: requestOptions) { [weak self] (livePhoto, info) in
            guard let self = self else { return }
            guard let info = info else {
                completion(.failure(.invalidInfo))
                return
            }
            if let livePhoto = livePhoto {
                completion(.success(.init(livePhoto: livePhoto)))
            } else {
                completion(.failure(.invalidLivePhoto))
            }
            let requestID = info[PHImageResultRequestIDKey] as? PHImageRequestID
            self.dequeueFetch(for: asset.localIdentifier, requestID: requestID)
        }
        enqueueFetch(for: asset.localIdentifier, requestID: requestID)
    }
}
