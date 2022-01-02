//
//  ExportTool+PhotoLive.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

public struct PhotoLiveFetchOptions {

    public let targetSize: CGSize
    public let version: PHImageRequestOptionsVersion
    public let deliveryMode: PHImageRequestOptionsDeliveryMode
    public let isNetworkAccessAllowed: Bool
    public let progressHandler: PHAssetImageProgressHandler?
    
    public init(targetSize: CGSize = .init(width: 500, height: 500),
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

public struct PhotoLiveFetchResponse {
    
    public let livePhoto: PHLivePhoto
}

public typealias PhotoLiveFetchCompletion = (Result<PhotoLiveFetchResponse, AnyImageError>, PHImageRequestID) -> Void


extension ExportTool {
    
    @discardableResult
    public static func requestPhotoLive(for asset: PHAsset, options: PhotoLiveFetchOptions = .init(), completion: @escaping PhotoLiveFetchCompletion) -> PHImageRequestID {
        let requestOptions = PHLivePhotoRequestOptions()
        requestOptions.version = options.version
        requestOptions.deliveryMode = options.deliveryMode
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.progressHandler = options.progressHandler
        
        return PHImageManager.default().requestLivePhoto(for: asset, targetSize: options.targetSize, contentMode: .aspectFill, options: requestOptions) { (livePhoto, info) in
            let requestID = (info?[PHImageResultRequestIDKey] as? PHImageRequestID) ?? 0
            if let livePhoto = livePhoto {
                completion(.success(.init(livePhoto: livePhoto)), requestID)
            } else {
                completion(.failure(.invalidLivePhoto), requestID)
            }
        }
    }
}
