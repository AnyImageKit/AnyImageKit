//
//  Asset+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/25.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Photos

extension Asset where Resource == PHAsset {
    
    init(phAsset: PHAsset, selectOption: MediaSelectOption, cache: AnyImageCacher) {
        let mediaType = MediaType(phAsset: phAsset, selectOption: selectOption)
        self.init(resource: phAsset, mediaType: mediaType, cacher: cache)
    }
    
    public var phAsset: PHAsset {
        return resource
    }
}

// MARK: - Image
extension Asset where Resource == PHAsset {
    
    /// Fetch Photo Data
    /// - Note: Only for `MediaType` Photo, GIF, LivePhoto
    /// - Parameter options: Photo Data Fetch Options
    /// - Parameter completion: Photo Data Fetch Completion
    @discardableResult
    public func fetchPhotoData(options: PhotoDataFetchOptions = .init(), completion: @escaping PhotoDataFetchCompletion) -> PHImageRequestID {
        guard phAsset.mediaType == .image else {
            completion(.failure(.invalidMediaType), 0)
            return 0
        }
        return ExportTool.requestPhotoData(for: phAsset, options: options, completion: completion)
    }
    
    /// Fetch Photo URL
    /// - Note: Only for `MediaType` Photo, PhotoGIF
    /// - Parameter options: Photo URL Fetch Options
    /// - Parameter completion: Photo URL Fetch Completion
    @discardableResult
    public func fetchPhotoURL(options: PhotoURLFetchOptions = .init(), completion: @escaping PhotoURLFetchCompletion) -> PHImageRequestID {
        guard phAsset.mediaType == .image else {
            completion(.failure(.invalidMediaType), 0)
            return 0
        }
        return ExportTool.requestPhotoURL(for: phAsset, options: options, completion: completion)
    }
}

// MARK: - Video
extension Asset where Resource == PHAsset {
    
    /// Fetch video `AVPlayerItem` for playback
    /// - Note: Only for `MediaType` Video
    /// - Parameter options: Video Fetch Options
    /// - Parameter completion: Video Fetch Completion
    @discardableResult
    public func fetchVideo(options: VideoFetchOptions = .init(), completion: @escaping VideoFetchCompletion) -> PHImageRequestID {
        guard phAsset.mediaType == .video else {
            completion(.failure(.invalidMediaType), 0)
            return 0
        }
        return ExportTool.requestVideo(for: phAsset, options: options, completion: completion)
    }
    
    /// Fetch video URL
    /// - Note: Only for `MediaType` Video
    /// - Parameter options: Video URL Fetch Options
    /// - Parameter completion: Video URL Fetch Completion
    @discardableResult
    public func fetchVideoURL(options: VideoURLFetchOptions = .init(), completion: @escaping VideoURLFetchCompletion) -> PHImageRequestID {
        guard phAsset.mediaType == .video else {
            completion(.failure(.invalidMediaType), 0)
            return 0
        }
        return ExportTool.requestVideoURL(for: phAsset, options: options, completion: completion)
    }
}
