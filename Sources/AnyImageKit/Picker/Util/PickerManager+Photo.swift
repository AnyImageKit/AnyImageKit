//
//  PickerManager+Photo.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import Kingfisher

struct _PhotoFetchOptions {
    
    let sizeMode: PhotoSizeMode
    let resizeMode: PHImageRequestOptionsResizeMode
    let version: PHImageRequestOptionsVersion
    let needCache: Bool
    let isNetworkAccessAllowed: Bool
    let progressHandler: PHAssetImageProgressHandler?
    
    init(sizeMode: PhotoSizeMode = .thumbnail(100),
         resizeMode: PHImageRequestOptionsResizeMode = .fast,
         version: PHImageRequestOptionsVersion = .current,
         needCache: Bool = true,
         isNetworkAccessAllowed: Bool = true,
         progressHandler: PHAssetImageProgressHandler? = nil) {
        self.sizeMode = sizeMode
        self.resizeMode = resizeMode
        self.version = version
        self.needCache = needCache
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
    }
    
    var targetSize: CGSize {
        switch sizeMode {
        case .thumbnail(let width):
            return CGSize(width: width, height: width)
        case .preview(let width):
            return CGSize(width: width, height: width)
        case .original:
            return PHImageManagerMaximumSize
        }
    }
}

enum PhotoSizeMode: Equatable {
    /// Thumbnail Size
    case thumbnail(CGFloat)
    /// Preview Size, based on your config
    case preview(CGFloat)
    /// Original Size
    case original
}

typealias _PhotoFetchCompletion = (Result<PhotoFetchResponse, AnyImageError>) -> Void
typealias _PhotoDataFetchCompletion = (Result<PhotoDataFetchResponse, AnyImageError>) -> Void
typealias _PhotoGIFFetchCompletion = (Result<PhotoGIFFetchResponse, AnyImageError>) -> Void
typealias _PhotoLiveFetchCompletion = (Result<PhotoLiveFetchResponse, AnyImageError>) -> Void

extension PickerManager {
    
    func requestPhoto(for album: Album, completion: @escaping _PhotoFetchCompletion) {
        if let asset = options.orderByDate == .asc ? album.assets.last : album.assets.first {
            let phAsset: PHAsset
            if asset.isCamera, let secondAsset = options.orderByDate == .asc ? album.assets.dropLast().last : album.assets.dropFirst().first {
                phAsset = secondAsset.phAsset
            } else {
                phAsset = asset.phAsset
            }
            let options = _PhotoFetchOptions(sizeMode: .thumbnail(100*UIScreen.main.nativeScale), needCache: false)
            requestPhoto(for: phAsset, options: options, completion: completion)
        }
    }
    
    func savePhoto(image: UIImage, completion: PhotoSaveCompletion? = nil) {
        ExportTool.savePhoto(image: image, completion: completion)
    }
    
    func savePhoto(url: URL, completion: PhotoSaveCompletion? = nil) {
        ExportTool.savePhoto(url: url, completion: completion)
    }
}

// MARK: - Request photo
extension PickerManager {
    
    func requestPhoto(for asset: PHAsset, options: _PhotoFetchOptions = .init(), completion: @escaping _PhotoFetchCompletion) {
        let fetchOptions = PhotoFetchOptions(size: options.targetSize, resizeMode: options.resizeMode, version: options.version, isNetworkAccessAllowed: options.isNetworkAccessAllowed, progressHandler: options.progressHandler)
        let requestID = ExportTool.requestPhoto(for: asset, options: fetchOptions) { (result, requestID) in
            switch result {
            case .success(let response):
                switch options.sizeMode {
                case .original:
                    completion(.success(.init(image: response.image, isDegraded: response.isDegraded)))
                case .preview:
                    self.workQueue.async { [weak self] in
                        guard let self = self else { return }
                        self.resizeSemaphore.wait()
                        let resizedImage = UIImage.resize(from: response.image, limitSize: options.targetSize, isExact: true)
                        self.resizeSemaphore.signal()
                        if !response.isDegraded && options.needCache {
                            self.cache.store(resizedImage, forKey: asset.localIdentifier)
                        }
                        DispatchQueue.main.async {
                            completion(.success(.init(image: resizedImage, isDegraded: response.isDegraded)))
                        }
                    }
                case .thumbnail:
                    if !response.isDegraded && options.needCache {
                        self.cache.store(response.image, forKey: asset.localIdentifier)
                    }
                    completion(.success(.init(image: response.image, isDegraded: response.isDegraded)))
                }
            case .failure(let error):
                guard error == .cannotFindInLocal && options.isNetworkAccessAllowed else {
                    completion(.failure(error))
                    return
                }
                // Download image from iCloud
                let photoDataOptions = PhotoDataFetchOptions(version: options.version,
                                                             isNetworkAccessAllowed: options.isNetworkAccessAllowed,
                                                             progressHandler: options.progressHandler)
                self.workQueue.async { [weak self] in
                    guard let self = self else { return }
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
                                self.resizeSemaphore.wait()
                                guard let resizedImage = UIImage.resize(from: response.data, limitSize: options.targetSize) else {
                                    self.resizeSemaphore.signal()
                                    DispatchQueue.main.async {
                                        completion(.failure(.invalidData))
                                    }
                                    return
                                }
                                self.resizeSemaphore.signal()
                                self.cache.store(resizedImage, forKey: asset.localIdentifier)
                                DispatchQueue.main.async {
                                    completion(.success(.init(image: resizedImage, isDegraded: false)))
                                }
                            case .thumbnail:
                                guard let resizedImage = UIImage.resize(from: response.data, limitSize: options.targetSize) else {
                                    DispatchQueue.main.async {
                                        completion(.failure(.invalidData))
                                    }
                                    return
                                }
                                DispatchQueue.main.async {
                                    completion(.success(.init(image: resizedImage, isDegraded: false)))
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
            self.dequeueFetch(for: asset.localIdentifier, requestID: requestID)
        }
        enqueueFetch(for: asset.localIdentifier, requestID: requestID)
    }
}

// MARK: - Request photo data
extension PickerManager {
    
    func requestPhotoData(for asset: PHAsset, options: PhotoDataFetchOptions = .init(), completion: @escaping (_PhotoDataFetchCompletion)) {
        let requestID = ExportTool.requestPhotoData(for: asset, options: options) { (result, requestID) in
            completion(result)
            self.dequeueFetch(for: asset.localIdentifier, requestID: requestID)
        }
        enqueueFetch(for: asset.localIdentifier, requestID: requestID)
    }
}

// MARK: - Request photo gif
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

extension PickerManager {
    
    func requsetPhotoGIF(for asset: PHAsset, options: PhotoGIFFetchOptions = .init(), completion: @escaping _PhotoGIFFetchCompletion) {
        let photoDataOptions = PhotoDataFetchOptions(version: .unadjusted,
                                                     isNetworkAccessAllowed: options.isNetworkAccessAllowed,
                                                     progressHandler: options.progressHandler)
        let requestID = ExportTool.requestPhotoData(for: asset, options: photoDataOptions) { result, requestID in
            switch result {
            case .success(let response):
                guard UTTypeConformsTo(response.dataUTI as CFString, kUTTypeGIF) else {
                    completion(.failure(.invalidDataUTI))
                    return
                }
                let creatingOptions = ImageCreatingOptions()
                guard let image = KingfisherWrapper<UIImage>.animatedImage(data: response.data, options: creatingOptions) else {
                    completion(.failure(.invalidImage))
                    return
                }
                completion(.success(.init(image: image)))
            case .failure(let error):
                completion(.failure(error))
            }
            self.dequeueFetch(for: asset.localIdentifier, requestID: requestID)
        }
        enqueueFetch(for: asset.localIdentifier, requestID: requestID)
    }
}

// MARK: - Request photo live
extension PickerManager {
    
    func requestPhotoLive(for asset: PHAsset, options: PhotoLiveFetchOptions = .init(), completion: @escaping _PhotoLiveFetchCompletion) {
        let requestID = ExportTool.requestPhotoLive(for: asset, options: options) { (result, requestID) in
            completion(result)
            self.dequeueFetch(for: asset.localIdentifier, requestID: requestID)
        }
        enqueueFetch(for: asset.localIdentifier, requestID: requestID)
    }
}
