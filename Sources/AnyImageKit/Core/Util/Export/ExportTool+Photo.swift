//
//  ExportTool+Photo.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

public struct PhotoFetchOptions {

    public let size: CGSize
    public let resizeMode: PHImageRequestOptionsResizeMode
    public let version: PHImageRequestOptionsVersion
    public let isNetworkAccessAllowed: Bool
    public let progressHandler: PHAssetImageProgressHandler?

    public init(size: CGSize = PHImageManagerMaximumSize,
                resizeMode: PHImageRequestOptionsResizeMode = .fast,
                version: PHImageRequestOptionsVersion = .current,
                isNetworkAccessAllowed: Bool = true,
                progressHandler: PHAssetImageProgressHandler? = nil) {
        self.size = size
        self.resizeMode = resizeMode
        self.version = version
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
    }
}

public struct PhotoFetchResponse {

    public let image: UIImage
    public let isDegraded: Bool
}

public typealias PhotoFetchCompletion = (Result<PhotoFetchResponse, AnyImageError>, PHImageRequestID) -> Void
public typealias PhotoSaveCompletion = (Result<PHAsset, AnyImageError>) -> Void

extension ExportTool {
    
    /// Fetch local photo 获取本地图片资源
    /// - Note: Fetch local photo only. If you want to fetch iCloud photo, please use `requestPhotoData` instead.
    /// - Note: 该方法仅用于获取本地图片资源，若要获取iCloud图片，请使用`requestPhotoData`方法。
    @discardableResult
    public static func requestPhoto(for asset: PHAsset, options: PhotoFetchOptions = .init(), completion: @escaping PhotoFetchCompletion) -> PHImageRequestID {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = options.version
        requestOptions.resizeMode = options.resizeMode
        requestOptions.isSynchronous = false

        let requestID = PHImageManager.default().requestImage(for: asset, targetSize: options.size, contentMode: .aspectFill, options: requestOptions) { (image, info) in
            let requestID = (info?[PHImageResultRequestIDKey] as? PHImageRequestID) ?? 0
            guard let info = info else {
                completion(.failure(.invalidInfo), requestID)
                return
            }
            let isCancelled = info[PHImageCancelledKey] as? Bool ?? false
            let error = info[PHImageErrorKey] as? Error
            let isDegraded = info[PHImageResultIsDegradedKey] as? Bool ?? false
            let isDownload = !isCancelled && error == nil
            if isDownload, let image = image {
                completion(.success(.init(image: image, isDegraded: isDegraded)), requestID)
            } else {
                let isInCloud = info[PHImageResultIsInCloudKey] as? Bool ?? false
                if isInCloud {
                    completion(.failure(AnyImageError.cannotFindInLocal), requestID)
                } else {
                    completion(.failure(AnyImageError.invalidData), requestID)
                }
            }
        }
        return requestID
    }

    public static func savePhoto(image: UIImage, completion: PhotoSaveCompletion? = nil) {
        // Write to album library
        var localIdentifier: String = ""
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            localIdentifier = request.placeholderForCreatedAsset?.localIdentifier ?? ""
        }) { (isSuccess, error) in
            DispatchQueue.main.async {
                if isSuccess {
                    if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                        completion?(.success(asset))
                    } else {
                        completion?(.failure(.savePhotoFailed))
                    }
                } else if let error = error {
                    _print("Save photo error: \(error.localizedDescription)")
                    completion?(.failure(.savePhotoFailed))
                }
            }
        }
    }
    
    public static func savePhoto(url: URL, completion: PhotoSaveCompletion? = nil) {
        var localIdentifier: String = ""
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier ?? ""
        }) { (isSuccess, error) in
            DispatchQueue.main.async {
                if isSuccess {
                    if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject {
                        completion?(.success(asset))
                    } else {
                        completion?(.failure(.savePhotoFailed))
                    }
                } else if let error = error {
                    _print("Save photo error: \(error.localizedDescription)")
                    completion?(.failure(.savePhotoFailed))
                }
            }
        }
    }
}
