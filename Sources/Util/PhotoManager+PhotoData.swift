//
//  PhotoManager+PhotoData.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos

public struct PhotoDataFetchOptions {
    
    public let version: PHImageRequestOptionsVersion
    public let isNetworkAccessAllowed: Bool
    public let progressHandler: PHAssetImageProgressHandler?
    
    public init(version: PHImageRequestOptionsVersion = .current,
                isNetworkAccessAllowed: Bool = true,
                progressHandler: PHAssetImageProgressHandler? = nil) {
        self.version = version
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
    }
}

public struct PhotoDataFetchResponse {
    
    public let data: Data
    public let dataUTI: String
    public let orientation: CGImagePropertyOrientation
}

public typealias PhotoDataFetchCompletion = (Result<PhotoDataFetchResponse, ImagePickerError>) -> Void

extension PhotoManager {
    
    public func requestPhotoData(for asset: PHAsset, options: PhotoDataFetchOptions = .init(), completion: @escaping PhotoDataFetchCompletion) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = options.version
        requestOptions.progressHandler = options.progressHandler
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.isSynchronous = true
        
        func handle(data: Data?, dataUTI: String?, orientation: CGImagePropertyOrientation, info: [AnyHashable: Any]?, completion: @escaping PhotoDataFetchCompletion) {
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            guard let dataUTI = dataUTI else {
                completion(.failure(.invalidDataUTI))
                return
            }
            completion(.success(.init(data: data, dataUTI: dataUTI, orientation: orientation)))
            let requestID = info?[PHImageResultRequestIDKey] as? PHImageRequestID
            self.dequeueFetch(for: asset, requestID: requestID)
        }
        
        if #available(iOS 13, *) {
            let requestID = PHImageManager.default().requestImageDataAndOrientation(for: asset, options: requestOptions) { (data, dataUTI, orientation, info) in
                handle(data: data, dataUTI: dataUTI, orientation: orientation, info: info, completion: completion)
            }
            enqueueFetch(for: asset, requestID: requestID)
        } else {
            let requestID = PHImageManager.default().requestImageData(for: asset, options: requestOptions) { (data, dataUTI, uiOrientation, info) in
                handle(data: data, dataUTI: dataUTI, orientation: .init(uiOrientation), info: info, completion: completion)
            }
            enqueueFetch(for: asset, requestID: requestID)
        }
    }
}
