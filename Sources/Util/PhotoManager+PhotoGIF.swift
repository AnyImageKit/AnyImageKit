//
//  PhotoManager+PhotoGIF.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Photos
import UIKit
import MobileCoreServices

struct PhotoGIFFetchOptions {
    
    let isNetworkAccessAllowed: Bool
    let version: PHImageRequestOptionsVersion
    let progressHandler: PHAssetImageProgressHandler?
    
    init(isNetworkAccessAllowed: Bool = true,
         version: PHImageRequestOptionsVersion = .current,
         progressHandler: PHAssetImageProgressHandler? = nil) {
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.version = version
        self.progressHandler = progressHandler
    }
}

struct PhotoGIFFetchResponse {
    
    let image: UIImage
}

typealias PhotoGIFFetchCompletion = (Result<PhotoGIFFetchResponse, ImagePickerError>) -> Void

extension PhotoManager {
    
    func requsetPhotoGIF(for asset: PHAsset, options: PhotoGIFFetchOptions = .init(), completion: @escaping PhotoGIFFetchCompletion) {
        let photoDataOptions = PhotoDataFetchOptions(version: .unadjusted,
                                                     isNetworkAccessAllowed: options.isNetworkAccessAllowed,
                                                     progressHandler: options.progressHandler)
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
                completion(.success(.init(image: image)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
