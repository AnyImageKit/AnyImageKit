//
//  ExportTool+PhotoURL.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos

public struct PhotoURLFetchOptions {
    
    public let version: PHImageRequestOptionsVersion
    public let isNetworkAccessAllowed: Bool
    public let progressHandler: PHAssetImageProgressHandler?
    public let preferredOutputPath: String
    
    public init(version: PHImageRequestOptionsVersion = .current,
                isNetworkAccessAllowed: Bool = true,
                progressHandler: PHAssetImageProgressHandler? = nil,
                preferredOutputPath: String? = nil) {
        self.version = version
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
        if let preferredOutputPath = preferredOutputPath {
            self.preferredOutputPath = preferredOutputPath
        } else {
            self.preferredOutputPath = FileHelper.temporaryDirectory(for: .photo)
        }
    }
}

public struct PhotoURLFetchResponse {
    
    public let url: URL
    public let dataUTI: String
    public let orientation: CGImagePropertyOrientation
}

public typealias PhotoURLFetchCompletion = (Result<PhotoURLFetchResponse, AnyImageError>, PHImageRequestID) -> Void


extension ExportTool {
    
    @discardableResult
    public static func requestPhotoURL(for asset: PHAsset, options: PhotoURLFetchOptions = .init(), completion: @escaping PhotoURLFetchCompletion) -> PHImageRequestID {
        let photoDataOptions = PhotoDataFetchOptions(version: options.version,
                                                     isNetworkAccessAllowed: options.isNetworkAccessAllowed,
                                                     progressHandler: options.progressHandler)
        return ExportTool.requestPhotoData(for: asset, options: photoDataOptions) { result, requestID in
            switch result {
            case .success(let response):
                guard let outputURL = FileHelper.write(photoData: response.data, utType: response.dataUTI as CFString) else {
                    completion(.failure(.fileWriteFailed), requestID)
                    return
                }
                completion(.success(.init(url: outputURL, dataUTI: response.dataUTI, orientation: response.orientation)), requestID)
            case .failure(let error):
                completion(.failure(error), requestID)
            }
        }
    }
}
