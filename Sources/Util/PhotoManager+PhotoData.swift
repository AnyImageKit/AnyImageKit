//
//  PhotoManager+PhotoData.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos

struct PhotoDataFetchOptions {
    
    let version: PHImageRequestOptionsVersion
    let isNetworkAccessAllowed: Bool
    let progressHandler: PHAssetImageProgressHandler?
    let resizeMode: PHImageRequestOptionsResizeMode
    
    init(version: PHImageRequestOptionsVersion = .current,
         isNetworkAccessAllowed: Bool = true,
         progressHandler: PHAssetImageProgressHandler? = nil,
         resizeMode: PHImageRequestOptionsResizeMode = .fast) {
        self.version = version
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
        self.resizeMode = resizeMode
    }
}

typealias PhotoDataFetchResponse = (data: Data, dataUTI: String, orientation: CGImagePropertyOrientation)
typealias PhotoDataFetchCompletion = (Result<PhotoDataFetchResponse, ImagePickerError>) -> Void

extension PhotoManager {
    
    func requestPhotoData(for asset: PHAsset, options: PhotoDataFetchOptions = .init(), completion: @escaping PhotoDataFetchCompletion) {
        
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
            completion(.success((data, dataUTI, orientation)))
        }
        
        if #available(iOS 13, *) {
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: requestOptions) { (data, dataUTI, orientation, info) in
                handle(data: data, dataUTI: dataUTI, orientation: orientation, info: info, completion: completion)
            }
        } else {
            PHImageManager.default().requestImageData(for: asset, options: requestOptions) { (data, dataUTI, orientation, info) in
                handle(data: data, dataUTI: dataUTI, orientation: CGImagePropertyOrientation(orientation), info: info, completion: completion)
            }
        }
    }
}
