//
//  ExportTool+PhotoGIF.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

public struct PhotoGIFFetchOptions {
    
    public let isNetworkAccessAllowed: Bool
    public let version: PHImageRequestOptionsVersion
    public let progressHandler: PHAssetImageProgressHandler?
    
    public init(isNetworkAccessAllowed: Bool = true,
                version: PHImageRequestOptionsVersion = .current,
                progressHandler: PHAssetImageProgressHandler? = nil) {
        self.isNetworkAccessAllowed = isNetworkAccessAllowed
        self.version = version
        self.progressHandler = progressHandler
    }
}

public struct PhotoGIFFetchResponse {
    
    public let image: UIImage
}

public typealias PhotoGIFFetchCompletion = (Result<PhotoGIFFetchResponse, ImageKitError>, PHImageRequestID) -> Void

extension ExportTool {
    
    @discardableResult
    public static func requsetPhotoGIF(for asset: PHAsset, options: PhotoGIFFetchOptions = .init(), completion: @escaping PhotoGIFFetchCompletion) -> PHImageRequestID {
        let photoDataOptions = PhotoDataFetchOptions(version: .unadjusted,
                                                     isNetworkAccessAllowed: options.isNetworkAccessAllowed,
                                                     progressHandler: options.progressHandler)
        return ExportTool.requestPhotoData(for: asset, options: photoDataOptions) { result, requestID in
            switch result {
            case .success(let response):
                guard UTTypeConformsTo(response.dataUTI as CFString, kUTTypeGIF) else {
                    completion(.failure(.invalidDataUTI), requestID)
                    return
                }
                let creatingOptions = ImageCreatingOptions()
                guard let image = UIImage.animatedImage(data: response.data, options: creatingOptions) else {
                    completion(.failure(.invalidImage), requestID)
                    return
                }
                completion(.success(.init(image: image)), requestID)
            case .failure(let error):
                completion(.failure(error), requestID)
            }
        }
    }
}
