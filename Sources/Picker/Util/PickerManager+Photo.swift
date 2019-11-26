//
//  PickerManager+Photo.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Photos
import UIKit

struct PhotoFetchOptions {
    
    let sizeMode: PhotoSizeMode
    let resizeMode: PHImageRequestOptionsResizeMode
    let version: PHImageRequestOptionsVersion
    let needCache: Bool
    let isNetworkAccessAllowed: Bool
    let progressHandler: PHAssetImageProgressHandler?
    
    init(sizeMode: PhotoSizeMode = .resize(100),
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
        case .resize(let width):
            return CGSize(width: width, height: width)
        case .preview(let width):
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
    case preview(CGFloat)
    /// Original Size
    case original
}

struct PhotoFetchResponse {
    
    let image: UIImage
    let isDegraded: Bool
}

typealias PhotoFetchCompletion = (Result<PhotoFetchResponse, ImagePickerError>) -> Void
typealias PhotoSaveCompletion = (Result<PHAsset, ImagePickerError>) -> Void

extension PickerManager {
    
    func requestPhoto(for album: Album, completion: @escaping PhotoFetchCompletion) {
        if let asset = config.orderByDate == .asc ? album.assets.last?.phAsset : album.assets.first?.phAsset {
            let scale = UIScreen.main.nativeScale
            let options = PhotoFetchOptions(sizeMode: .resize(100*scale), needCache: false)
            requestPhoto(for: asset, options: options, completion: completion)
        }
    }
    
    func requestPhoto(for asset: PHAsset, options: PhotoFetchOptions = .init(), completion: @escaping PhotoFetchCompletion) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = options.version
        requestOptions.resizeMode = options.resizeMode
        requestOptions.isSynchronous = false
        
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
                    self.workQueue.async { [weak self] in
                        guard let self = self else { return }
                        self.resizeSemaphore.wait()
                        let resizedImage = UIImage.resize(from: image, limitSize: options.targetSize, isExact: true)
                        self.resizeSemaphore.signal()
                        if !isDegraded && options.needCache {
                            self.cache.write(resizedImage, identifier: asset.localIdentifier)
                        }
                        DispatchQueue.main.async {
                            completion(.success(.init(image: resizedImage, isDegraded: isDegraded)))
                        }
                    }
                case .resize:
                    let resizedImage = UIImage.resize(from: image, limitSize: options.targetSize, isExact: false)
                    if !isDegraded && options.needCache {
                        self.cache.write(resizedImage, identifier: asset.localIdentifier)
                    }
                    completion(.success(.init(image: resizedImage, isDegraded: isDegraded)))
                }
            } else {
                // Download image from iCloud
                let isInCloud = info[PHImageResultIsInCloudKey] as? Bool ?? false
                if isInCloud && image == nil && options.isNetworkAccessAllowed {
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
                                    self.cache.write(resizedImage, identifier: asset.localIdentifier)
                                    DispatchQueue.main.async {
                                        completion(.success(.init(image: resizedImage, isDegraded: false)))
                                    }
                                case .resize:
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
            }
            let requestID = info[PHImageResultRequestIDKey] as? PHImageRequestID
            self.dequeueFetch(for: asset.localIdentifier, requestID: requestID)
        }
        enqueueFetch(for: asset.localIdentifier, requestID: requestID)
    }
    
    func savePhoto(_ image: UIImage, metadata: [String: Any] = [:], completion: PhotoSaveCompletion? = nil) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            completion?(.failure(.savePhotoFail))
            return
        }
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        let filePath = NSTemporaryDirectory().appending("PHOTO-SAVED-\(timestamp).jpg")
        FileHelper.createDirectory(at: NSTemporaryDirectory())
        let url = URL(fileURLWithPath: filePath)
        // Write to file
        do {
            try imageData.write(to: url)
        } catch {
            completion?(.failure(.savePhotoFail))
        }
        
        // Write to library
        var localIdentifier: String = ""
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier ?? ""
        }) { (isSuccess, error) in
            try? FileManager.default.removeItem(atPath: filePath)
            DispatchQueue.main.async {
                if isSuccess {
                    if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                        completion?(.success(asset))
                    } else {
                        completion?(.failure(.savePhotoFail))
                    }
                } else if error != nil {
                    _print("Save photo error: \(error!.localizedDescription)")
                    completion?(.failure(.savePhotoFail))
                }
            }
        }
    }
}
