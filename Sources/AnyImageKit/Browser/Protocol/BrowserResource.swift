//
//  BrowserResource.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2025/10/10.
//  Copyright © 2025 AnyImageKit.org. All rights reserved.
//


import UIKit
import Photos
import Kingfisher

// TODO: Move to core

public struct BrowserFetchResult {
    public let image: UIImage?
    public let progress: CGFloat
    
    init(_ image: UIImage?, _ progress: CGFloat) {
        self.image = image
        self.progress = progress
    }
}

public protocol BrowserResource {
    func loadImage(completion: @escaping (Result<BrowserFetchResult, AnyImageError>) -> Void)
}

extension UIImage: BrowserResource {
    public func loadImage(completion: @escaping (Result<BrowserFetchResult, AnyImageError>) -> Void) {
        completion(.success(.init(self, 1.0)))
    }
}

extension URL: BrowserResource {
    
    public func loadImage(completion: @escaping (Result<BrowserFetchResult, AnyImageError>) -> Void) {
        if isFileURL {
            do {
                let data = try Data(contentsOf: self)
                if let image = UIImage(data: data) {
                    completion(.success(.init(image, 1.0)))
                } else {
                    completion(.failure(.invalidImage))
                }
            } catch {
                _print(error.localizedDescription)
                completion(.failure(.invalidData))
            }
        } else {
            KingfisherManager.shared.retrieveImage(with: self, options: nil, progressBlock: { receivedSize, totalSize in
                let progress = CGFloat(receivedSize) / CGFloat(totalSize)
                completion(.success(.init(nil, progress)))
            }) { result in
                switch result {
                case .success(let value):
                    completion(.success(.init(value.image, 1.0)))
                case .failure(let error):
                    _print(error.localizedDescription)
                    completion(.failure(.invalidURL))
                }
            }
        }
    }
}

extension PHAsset: BrowserResource {
    
    public func loadImage(completion: @escaping (Result<BrowserFetchResult, AnyImageError>) -> Void) {
        let cache = ImageCacheTool(module: .picker(.default), memoryCountLimit: 20)
        loadImage(cache: cache, completion: completion)
    }
    
    func loadImage(cache: ImageCacheTool, completion: @escaping (Result<BrowserFetchResult, AnyImageError>) -> Void) {
        if let image = cache.retrieveImage(forKey: localIdentifier) {
            completion(.success(.init(image, 1.0)))
            return
        }
        
        let targetSize = CGSize(width: 1800, height: 1800)
        let fetchOptions = PhotoFetchOptions(size: targetSize)
        ExportTool.requestPhoto(for: self, options: fetchOptions) { [weak self] (result, requestID) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                completion(.success(.init(response.image, 1.0)))
                if !response.isDegraded {
                    cache.store(response.image, forKey: self.localIdentifier)
                }
            case .failure(let error):
                guard error == .cannotFindInLocal else {
                    completion(.failure(error))
                    return
                }
                // Download image from iCloud
                let photoDataOptions = PhotoDataFetchOptions { (progress, error, isAtEnd, info) in
                    completion(.success(.init(nil, progress)))
                }
                ExportTool.requestPhotoData(for: self, options: photoDataOptions) { [weak self] (result, requestID) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let response):
                        guard let resizedImage = UIImage.resize(from: response.data, limitSize: targetSize) else {
                            completion(.failure(.invalidData))
                            return
                        }
                        cache.store(resizedImage, forKey: self.localIdentifier)
                        completion(.success(.init(resizedImage, 1.0)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
