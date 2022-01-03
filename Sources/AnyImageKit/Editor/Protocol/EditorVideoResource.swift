//
//  EditorVideoResource.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/18.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

public protocol EditorVideoResource {
    func loadURL(completion: @escaping (Result<URL, AnyImageError>) -> Void)
}

extension URL: EditorVideoResource {
    
    public func loadURL(completion: @escaping (Result<URL, AnyImageError>) -> Void) {
        if self.isFileURL {
            completion(.success(self))
        } else {
            completion(.failure(.invalidURL))
        }
    }
}

extension PHAsset: EditorVideoResource {
    
    public func loadURL(completion: @escaping (Result<URL, AnyImageError>) -> Void) {
        guard mediaType == .video || mediaSubtypes == .photoLive else {
            completion(.failure(.invalidMediaType))
            return
        }
        // Load from current device
        PHCachingImageManager().requestAVAsset(forVideo: self, options: nil) { [weak self] (asset, audioMix, info) in
            if let avAsset = asset as? AVURLAsset {
                completion(.success(avAsset.url))
            } else { // Load from network
                completion(.failure(.cannotFindInLocal))
                self?.loadURLFromNetwork(completion: completion)
            }
        }
    }
    
    private func loadURLFromNetwork(completion: @escaping (Result<URL, AnyImageError>) -> Void) {
        let options = VideoURLFetchOptions(isNetworkAccessAllowed: true, version: .current, deliveryMode: .highQualityFormat, fetchProgressHandler: { (progress, _, _, _) in
            _print("Download video from iCloud: \(progress)")
        })
        
        ExportTool.requestVideoURL(for: self, options: options) { (result, _) in
            switch result {
            case .success(let response):
                completion(.success(response.url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
