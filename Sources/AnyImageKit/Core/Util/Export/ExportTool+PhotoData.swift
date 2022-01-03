//
//  ExportTool+PhotoData.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
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

public typealias PhotoDataFetchCompletion = (Result<PhotoDataFetchResponse, AnyImageError>, PHImageRequestID) -> Void


extension ExportTool {
    
    @discardableResult
    public static func requestPhotoData(for asset: PHAsset, options: PhotoDataFetchOptions = .init(), completion: @escaping PhotoDataFetchCompletion) -> PHImageRequestID {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = options.version
        requestOptions.progressHandler = options.progressHandler
        requestOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        requestOptions.isSynchronous = false
        
        func handle(data: Data?, dataUTI: String?, orientation: CGImagePropertyOrientation, info: [AnyHashable: Any]?, completion: @escaping PhotoDataFetchCompletion) {
            let requestID = (info?[PHImageResultRequestIDKey] as? PHImageRequestID) ?? 0
            guard let data = data else {
                completion(.failure(.invalidData), requestID)
                return
            }
            guard let dataUTI = dataUTI else {
                completion(.failure(.invalidDataUTI), requestID)
                return
            }
            completion(.success(.init(data: data, dataUTI: dataUTI, orientation: orientation)), requestID)
        }
        
        if #available(iOS 13.0, *) {
            return PHImageManager.default().requestImageDataAndOrientation(for: asset, options: requestOptions) { (data, dataUTI, orientation, info) in
                handle(data: data, dataUTI: dataUTI, orientation: orientation, info: info, completion: completion)
            }
        } else {
            return PHImageManager.default().requestImageData(for: asset, options: requestOptions) { (data, dataUTI, uiOrientation, info) in
                handle(data: data, dataUTI: dataUTI, orientation: .init(uiOrientation), info: info, completion: completion)
            }
        }
    }
}
