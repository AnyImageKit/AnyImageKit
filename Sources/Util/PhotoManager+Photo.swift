//
//  PhotoManager+Photo.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos
import UIKit

public struct PhotoFetchOptions {
    
    public let sizeMode: PhotoSizeMode
    public let resizeMode: PHImageRequestOptionsResizeMode
    public let version: PHImageRequestOptionsVersion
    public let isNetworkAccessAllowed: Bool
    public let progressHandler: PHAssetImageProgressHandler?
    
    public init(sizeMode: PhotoSizeMode = .resize(100),
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
}

public enum PhotoSizeMode: Equatable {
    /// Custom Size
    case resize(CGFloat)
    /// Preview Size, based on your screen width
    case preview
    /// Original Size
    case original
    
    var targetSize: CGSize {
        switch self {
        case .resize(let width):
            return CGSize(width: width, height: width)
        case .preview:
            return UIScreen.main.nativeBounds.size
        case .original:
            return PHImageManagerMaximumSize
        }
    }
}

public struct PhotoFetchResponse {
    
    public let image: UIImage
    public let isDegraded: Bool
}

public typealias PhotoFetchCompletion = (Result<PhotoFetchResponse, ImagePickerError>) -> Void

extension PhotoManager {
    
    func requestPhoto(for album: Album, completion: @escaping PhotoFetchCompletion) {
        if let asset = config.orderByDate == .asc ? album.result.lastObject : album.result.firstObject {
            let sacle = UIScreen.main.nativeScale
            let options = PhotoFetchOptions(sizeMode: .resize(55*sacle))
            requestPhoto(for: asset, options: options, completion: completion)
        }
    }
    
    public func requestPhoto(for asset: PHAsset, options: PhotoFetchOptions = .init(), completion: @escaping PhotoFetchCompletion) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = options.version
        requestOptions.resizeMode = options.resizeMode
        
        let requestID = PHImageManager.default().requestImage(for: asset, targetSize: options.sizeMode.targetSize, contentMode: .aspectFill, options: requestOptions) { [weak self] (image, info) in
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
                    let resizedImage = UIImage.resize(from: image, size: options.sizeMode.targetSize)
                    if !isDegraded {
                        self.writeCache(image: image, for: asset.localIdentifier)
                    }
                    completion(.success(.init(image: resizedImage, isDegraded: isDegraded)))
                case .resize:
                    let resizedImage = UIImage.resize(from: image, size: options.sizeMode.targetSize)
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
                                    let size = self.calculateSize(from: asset.pixelSize, to: options.sizeMode.targetSize)
                                    guard let image = UIImage.resize(from: response.data, size: size) else {
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
                                    let size = self.calculateSize(from: asset.pixelSize, to: options.sizeMode.targetSize)
                                    guard let image = UIImage.resize(from: response.data, size: size) else {
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
    
    private func calculateSize(from assetSize: CGSize, to targetSize: CGSize) -> CGSize {
        let aspectRatio = assetSize.width / assetSize.height
        var width = targetSize.width * aspectRatio
        if aspectRatio > 1.8 {
            width = width * aspectRatio
        }
        if aspectRatio < 0.2 {
            width = width * 0.5
        }
        let height = width / aspectRatio
        return CGSize(width: width, height: height)
    }
}
