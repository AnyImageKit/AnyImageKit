//
//  AnyImageFetcher+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/10.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos
import ImageIO

struct ImagePhotoLoadOptions {
    
    let size: CGSize
    let resizeMode: PHImageRequestOptionsResizeMode
    let version: PHImageRequestOptionsVersion
    let isNetworkAccessAllowed: Bool
    let progressHandler: PHAssetImageProgressHandler?
    
    init(size: CGSize = PHImageManagerMaximumSize,
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

struct ImagePhotoDataLoadOptions {
    
    let version: PHImageRequestOptionsVersion
    let isNetworkAccessAllowed: Bool
    let progressHandler: PHAssetImageProgressHandler?
    
    init(version: PHImageRequestOptionsVersion = .current,
         isNetworkAccessAllowed: Bool = true,
         progressHandler: PHAssetImageProgressHandler? = nil) {
        self.version = version
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
    }
}

struct ImageLivePhotoLoadOptions {
    
    let targetSize: CGSize
    let version: PHImageRequestOptionsVersion
    let deliveryMode: PHImageRequestOptionsDeliveryMode
    let isNetworkAccessAllowed: Bool
    let progressHandler: PHAssetImageProgressHandler?
    
    init(targetSize: CGSize = .init(width: 500, height: 500),
         version: PHImageRequestOptionsVersion = .current,
         deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat,
         isNetworkAccessAllowed: Bool = true,
         progressHandler: PHAssetImageProgressHandler? = nil) {
        self.targetSize = targetSize
        self.version = version
        self.deliveryMode = deliveryMode
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.progressHandler = progressHandler
    }
}
typealias PhotoLoadCompletion = (Result<PhotoLoadResponse, AnyImageError>) -> Void
typealias PhotoDataLoadCompletion = (Result<PhotoDataLoadResponse, AnyImageError>) -> Void
typealias LivePhotoLoadCompletion = (Result<LivePhotoLoadResponse, AnyImageError>) -> Void

struct PhotoLoadResponse: IdentifiableResource {
    
    let identifier: String
    let image: UIImage
    let isDegraded: Bool
}

struct PhotoDataLoadResponse: IdentifiableResource {
    
    let identifier: String
    let data: Data
    let dataUTI: String
    let orientation: CGImagePropertyOrientation
}

struct LivePhotoLoadResponse: IdentifiableResource {
    
    let identifier: String
    let livePhoto: PHLivePhoto
}

extension AnyImageFetcher {
    
    func loadPhoto(resource: PHAsset, loadOptions: ImagePhotoLoadOptions = .init(), completion: @escaping PhotoLoadCompletion) {
        let phRequestOptions = PHImageRequestOptions()
        phRequestOptions.version = loadOptions.version
        phRequestOptions.resizeMode = loadOptions.resizeMode
        phRequestOptions.isSynchronous = false
        phRequestOptions.isNetworkAccessAllowed = loadOptions.isNetworkAccessAllowed
        let identifier = resource.identifier
        let requestInID = PHImageManager.default().requestImage(for: resource,
                                                                targetSize: loadOptions.size,
                                                                contentMode: .aspectFill,
                                                                options: phRequestOptions)
        { [weak self] (image, info) in
            guard let self = self else { return }
            guard let info = info, let requestOutID = info[PHImageResultRequestIDKey] as? PHImageRequestID else {
                completion(.failure(.invalidInfo))
                return
            }
            defer {
                self.endRequest(id: Int(requestOutID), identifier: identifier)
            }
            let isCancelled = info[PHImageCancelledKey] as? Bool ?? false
            let error = info[PHImageErrorKey] as? Error // FIXME: throw error out
            let isDegraded = info[PHImageResultIsDegradedKey] as? Bool ?? false
            let isDownloaded = !isCancelled && error == nil
            if isDownloaded, let image = image {
                completion(.success(.init(identifier: identifier, image: image, isDegraded: isDegraded)))
            } else {
                let isInCloud = info[PHImageResultIsInCloudKey] as? Bool ?? false
                if isInCloud {
                    completion(.failure(AnyImageError.resourceIsInCloud))
                } else {
                    completion(.failure(AnyImageError.invalidData))
                }
            }
        }
        self.startRequest(id: Int(requestInID), identifier: identifier)
    }
    
    func loadPhotoData(resource: PHAsset, loadOptions: ImagePhotoDataLoadOptions = .init(), completion: @escaping PhotoDataLoadCompletion) {
        
        
    }
    
    func loadLivePhoto(resource: PHAsset, loadOptions: ImageLivePhotoLoadOptions = .init(), completion: @escaping LivePhotoLoadCompletion) {
        
    }
}
