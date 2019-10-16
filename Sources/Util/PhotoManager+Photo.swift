//
//  PhotoManager+Photo.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos
import UIKit

struct PhotoFetchOptions {
    
    let sizeMode: PhotoSizeMode
    let resizeMode: PHImageRequestOptionsResizeMode
    let version: PHImageRequestOptionsVersion
    let isNetworkAccessAllowed: Bool
    let progressHandler: PHAssetImageProgressHandler?
    
    init(sizeMode: PhotoSizeMode = .resize(100),
         resizeMode: PHImageRequestOptionsResizeMode = .fast,
         version: PHImageRequestOptionsVersion = .current,
         isNetworkAccessAllowed: Bool = true,
         progressHandler: PHAssetImageProgressHandler? = nil) {
        self.sizeMode = sizeMode
        self.resizeMode = resizeMode
        self.version = version
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
    }
    
    var targetSize: CGSize {
        switch sizeMode {
        case .resize(let width):
            return CGSize(width: width, height: width)
        case .preview:
            let width = PhotoManager.shared.config.largePhotoMaxWidth
            return CGSize(width: width, height: width)
        case .original:
            return PHImageManagerMaximumSize
        }
    }
}

enum PhotoSizeMode: Equatable {
    /// Custom Size
    case resize(CGFloat)
    /// Preview Size, based on your config
    case preview
    /// Original Size
    case original
}

struct PhotoFetchResponse {
    
    let image: UIImage
    let isDegraded: Bool
}

typealias PhotoFetchCompletion = (Result<PhotoFetchResponse, ImagePickerError>) -> Void

extension PhotoManager {
    
    func requestPhoto(for album: Album, completion: @escaping PhotoFetchCompletion) {
        if let asset = config.orderByDate == .asc ? album.result.lastObject : album.result.firstObject {
            let sacle = UIScreen.main.nativeScale
            let options = PhotoFetchOptions(sizeMode: .resize(100*sacle))
            requestPhoto(for: asset, options: options, completion: completion)
        }
    }
    
    func requestPhoto(for asset: PHAsset, options: PhotoFetchOptions = .init(), completion: @escaping PhotoFetchCompletion) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = options.version
        requestOptions.resizeMode = options.resizeMode
        
        let requestID = PHImageManager.default().requestImage(for: asset, targetSize: options.targetSize, contentMode: .aspectFill, options: requestOptions) { [weak self] (image, info) in
            guard let self = self else { return }
            guard let info = info else {
                completion(.failure(.invalidInfo))
                return
            }
            let isCancelled = info[PHImageCancelledKey] as? Bool ?? false
            let error = info[PHImageErrorKey] as? Error
            let isDegraded = info[PHImageResultIsDegradedKey] as? Bool ?? false
            let isDownload = !isCancelled && error == nil
            if isDownload, let image = image {
                switch options.sizeMode {
                case .original:
                    completion(.success(.init(image: image, isDegraded: isDegraded)))
                case .preview:
                    let resizedImage = UIImage.resize(from: image, limitSize: options.targetSize)
                    if !isDegraded {
                        self.writeCache(image: image, for: asset.localIdentifier)
                    }
                    completion(.success(.init(image: resizedImage, isDegraded: isDegraded)))
                case .resize:
                    let resizedImage = UIImage.resize(from: image, limitSize: options.targetSize)
                    completion(.success(.init(image: resizedImage, isDegraded: isDegraded)))
                }
            } else {
                // Download image from iCloud
                print("Download image from iCloud")
                let isInCloud = info[PHImageResultIsInCloudKey] as? Bool ?? false
                if isInCloud && image == nil && options.isNetworkAccessAllowed {
                    let photoDataOptions = PhotoDataFetchOptions(isNetworkAccessAllowed: options.isNetworkAccessAllowed,
                                                                 progressHandler: options.progressHandler)
                    self.workQueue.async {
                        self.requestPhotoData(for: asset, options: photoDataOptions) { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success(let response):
                                switch options.sizeMode {
                                case .original:
                                    guard let image = UIImage(data: response.data) else {
                                        DispatchQueue.main.async {
                                            completion(.failure(.invalidData))
                                        }
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        completion(.success(.init(image: image, isDegraded: false)))
                                    }
                                case .preview:
                                    guard let image = UIImage.resize(from: response.data, limitSize: options.targetSize) else {
                                        DispatchQueue.main.async {
                                            completion(.failure(.invalidData))
                                        }
                                        return
                                    }
                                    self.writeCache(image: image, for: asset.localIdentifier)
                                    DispatchQueue.main.async {
                                        completion(.success(.init(image: image, isDegraded: false)))
                                    }
                                case .resize:
                                    guard let image = UIImage.resize(from: response.data, limitSize: options.targetSize) else {
                                        DispatchQueue.main.async {
                                            completion(.failure(.invalidData))
                                        }
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        completion(.success(.init(image: image, isDegraded: false)))
                                    }
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    completion(.failure(error))
                                }
                            }
                        }
                    }
                }
            }
            let requestID = info[PHImageResultRequestIDKey] as? PHImageRequestID
            self.dequeueFetch(for: asset, requestID: requestID)
        }
        enqueueFetch(for: asset, requestID: requestID)
    }
}
