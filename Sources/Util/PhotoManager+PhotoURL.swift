//
//  PhotoManager+PhotoURL.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/10/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
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
                preferredOutputPath: String = NSTemporaryDirectory()) {
        self.version = version
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
        self.preferredOutputPath = preferredOutputPath
    }
}

public struct PhotoURLFetchResponse {
    
    public let url: URL
    public let dataUTI: String
    public let orientation: CGImagePropertyOrientation
}

public typealias PhotoURLFetchCompletion = (Result<PhotoURLFetchResponse, ImagePickerError>) -> Void

extension PhotoManager {
    
    func requestPhotoURL(for asset: PHAsset, options: PhotoURLFetchOptions = .init(), completion: @escaping PhotoURLFetchCompletion) {
        let photoDataOptions = PhotoDataFetchOptions(version: options.version,
                                                     isNetworkAccessAllowed: options.isNetworkAccessAllowed,
                                                     progressHandler: options.progressHandler)
        requestPhotoData(for: asset, options: photoDataOptions) { result in
            switch result {
            case .success(let response):
                // Check Path
                FileHelper.checkDirectory(path: options.preferredOutputPath)
                // Prepare Output URL
                let timestamp = Int(Date().timeIntervalSince1970)
                let outputPath = options.preferredOutputPath.appending("/PHOTO-\(timestamp)).\(FileHelper.fileExtension(from: response.dataUTI as CFString))")
                let outputURL = URL(fileURLWithPath: outputPath)
                // Write to File
                do {
                    try response.data.write(to: outputURL)
                } catch {
                    completion(.failure(.exportFail))
                    return 
                }
                completion(.success(.init(url: outputURL, dataUTI: response.dataUTI, orientation: response.orientation)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
