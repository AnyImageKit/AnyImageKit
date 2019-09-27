//
//  PhotoManager+PhotoGIF.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos
import UIKit
import MobileCoreServices

struct PhotoGIFFetchOptions {
    
    let isNetworkAccessAllowed: Bool
    let progressHandler: PHAssetImageProgressHandler?
    
    init(isNetworkAccessAllowed: Bool = true,
         progressHandler: PHAssetImageProgressHandler? = nil) {
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
    }
}

typealias PhotoGIFFetchResponse = UIImage
typealias PhotoGIFFetchCompletion = (Result<PhotoGIFFetchResponse, ImagePickerError>) -> Void

extension PhotoManager {
    
    func requsetPhotoGIF(for asset: PHAsset, options: PhotoGIFFetchOptions = .init(), completion: @escaping PhotoGIFFetchCompletion) {
        let photoDataOptions = PhotoDataFetchOptions(version: .unadjusted,
                                                     isNetworkAccessAllowed: options.isNetworkAccessAllowed,
                                                     progressHandler: options.progressHandler,
                                                     resizeMode: .fast)
        self.requestPhotoData(for: asset, options: photoDataOptions) { result in
            switch result {
            case .success(let response):
                guard UTTypeConformsTo(response.dataUTI as CFString, kUTTypeGIF) else {
                    completion(.failure(.invalidDataUTI))
                    return
                }
                let creatingOptions = ImageCreatingOptions()
                guard let image = UIImage.animatedImage(data: response.data, options: creatingOptions) else {
                    completion(.failure(.invalidImage))
                    return
                }
                completion(.success((image)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
