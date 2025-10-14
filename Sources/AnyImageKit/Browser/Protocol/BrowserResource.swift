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
import AVFoundation
import MobileCoreServices

public struct BrowserFetchResult {
    public let image: UIImage?
    public let progress: CGFloat
    
    init(_ image: UIImage?, _ progress: CGFloat) {
        self.image = image
        self.progress = progress
    }
}

/// 浏览器资源类型枚举
public enum BrowserResource {
    /// A UIImage object already in memory.
    case image(UIImage)
    
    /// An asset from the PhotoKit library. Can be an image, video, or Live Photo.
    case phAsset(PHAsset)
    
    /// A remote image specified by a URL.
    case remoteImage(URL)
    
    /// A local file specified by a URL. The framework will determine if it's an image or video.
    case localFile(URL)
    
    /// A remote video. Requires a video URL and an optional thumbnail URL.
    case remoteVideo(url: URL, thumbnailURL: URL?)
}

// MARK: - Centralized Logic
extension BrowserResource {
    
    /// 加载与资源对应的图片
    public func loadImage(completion: @escaping (Result<BrowserFetchResult, AnyImageError>) -> Void) {
        switch self {
        case .image(let image):
            completion(.success(.init(image, 1.0)))
            
        case .phAsset(let asset):
            loadPHAsset(asset, completion: completion)
            
        case .remoteImage(let url):
            loadRemoteImage(url, completion: completion)
            
        case .localFile(let url):
            loadLocalFile(url, completion: completion)
            
        case .remoteVideo(_, let thumbnailURL):
            guard let url = thumbnailURL else {
                completion(.failure(.invalidURL))
                return
            }
            loadRemoteImage(url, completion: completion)
        }
    }
    
    // MARK: - Private Helper Functions
    
    private func loadPHAsset(_ asset: PHAsset, completion: @escaping (Result<BrowserFetchResult, AnyImageError>) -> Void) {
        let cache = ImageCacheTool(module: .picker(.default), memoryCountLimit: 20)
        if let image = cache.retrieveImage(forKey: asset.localIdentifier) {
            completion(.success(.init(image, 1.0)))
            return
        }
        
        let targetSize = CGSize(width: 1800, height: 1800)
        let fetchOptions = PhotoFetchOptions(size: targetSize)
        ExportTool.requestPhoto(for: asset, options: fetchOptions) { (result, requestID) in
            switch result {
            case .success(let response):
                completion(.success(.init(response.image, 1.0)))
                if !response.isDegraded {
                    cache.store(response.image, forKey: asset.localIdentifier)
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
                ExportTool.requestPhotoData(for: asset, options: photoDataOptions) { (result, requestID) in
                    switch result {
                    case .success(let response):
                        guard let resizedImage = UIImage.resize(from: response.data, limitSize: targetSize) else {
                            completion(.failure(.invalidData))
                            return
                        }
                        cache.store(resizedImage, forKey: asset.localIdentifier)
                        completion(.success(.init(resizedImage, 1.0)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func loadRemoteImage(_ url: URL, completion: @escaping (Result<BrowserFetchResult, AnyImageError>) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: { receivedSize, totalSize in
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
    
    private func loadLocalFile(_ url: URL, completion: @escaping (Result<BrowserFetchResult, AnyImageError>) -> Void) {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, url.pathExtension as CFString, nil)?.takeRetainedValue() else {
            completion(.failure(.invalidURL))
            return
        }
        
        if UTTypeConformsTo(uti, kUTTypeMovie) {
            // 提取视频缩略图
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 0.1, preferredTimescale: 600)
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { (_, cgImage, _, _, _) in
                DispatchQueue.main.async {
                    if let cgImage = cgImage {
                        completion(.success(.init(UIImage(cgImage: cgImage), 1.0)))
                    } else {
                        completion(.failure(.invalidData))
                    }
                }
            }
        } else if UTTypeConformsTo(uti, kUTTypeImage) {
            // 加载本地图片
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    completion(.success(.init(image, 1.0)))
                } else {
                    completion(.failure(.invalidImage))
                }
            } catch {
                completion(.failure(.invalidData))
            }
        } else {
            completion(.failure(.invalidURL))
        }
    }
}
