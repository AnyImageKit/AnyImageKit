//
//  AnyImageLoader+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/7/10.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

struct PhotoLoadOptions {
    
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

typealias PhotoLoadCompletion = (Result<PhotoLoadResponse, AnyImageError>) -> Void

struct PhotoLoadResponse: IdentifiableResource {
    
    let identifier: String
    let image: UIImage
    let isDegraded: Bool
}

extension AnyImageLoader {
    
    func loadPhoto(asset: PHAsset, loadOptions: PhotoLoadOptions = .init(), completion: @escaping PhotoLoadCompletion) {
        let phRequestOptions = PHImageRequestOptions()
        phRequestOptions.version = loadOptions.version
        phRequestOptions.resizeMode = loadOptions.resizeMode
        phRequestOptions.isSynchronous = false
        phRequestOptions.isNetworkAccessAllowed = loadOptions.isNetworkAccessAllowed
        let identifier = asset.identifier
        let requestInID = PHImageManager.default().requestImage(for: asset,
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
                self.endRequest(id: requestOutID, for: identifier)
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
        self.startResuest(id: requestInID, for: identifier)
    }
}
