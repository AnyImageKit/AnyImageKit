//
//  Asset.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import Photos

public class Asset: Equatable {
    
    public let phAsset: PHAsset
    public let type: MediaType
    public internal(set) var image: UIImage = UIImage()
    
    let idx: Int
    let videoDuration: String
    var isSelected: Bool = false
    var selectedNum: Int = 1
    
    init(idx: Int, asset: PHAsset) {
        self.idx = idx
        self.phAsset = asset
        self.type = MediaType(asset: asset)
        self.videoDuration = asset.videoDuration
    }
    
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.phAsset.localIdentifier == rhs.phAsset.localIdentifier
    }
}

// MARK: - Original Photo
extension Asset {
    
    /// Fetch Photo Data 获取原图数据
    /// - Note: Only for `MediaType` Photo, PhotoGIF 仅用于媒体类型为照片、GIF
    /// - Parameter options: Photo Data Fetch Options 原图获取选项
    /// - Parameter completion: Photo Data Fetch Completion 原图获取结果回调
    public func fetchPhotoData(options: PhotoDataFetchOptions = .init(), completion: @escaping PhotoDataFetchCompletion) {
        guard type == .photo || type == .photoGif else {
            completion(.failure(.invalidMediaType))
            return
        }
        PhotoManager.shared.requestPhotoData(for: phAsset, options: options, completion: completion)
    }
    
    /// Fetch Photo URL 获取原图路径
    /// - Note: Only for `MediaType` Photo, PhotoGIF 仅用于媒体类型为照片、GIF
    /// - Parameter options: Photo URL Fetch Options 原图路径获取选项
    /// - Parameter completion: Photo URL Fetch Completion 原图路径获取结果回调
    public func fetchPhotoURL(options: PhotoURLFetchOptions = .init(), completion: @escaping PhotoURLFetchCompletion) {
        guard type == .photo || type == .photoGif else {
            completion(.failure(.invalidMediaType))
            return
        }
        PhotoManager.shared.requestPhotoURL(for: phAsset, options: options, completion: completion)
    }
}

// MARK: - Video
extension Asset {
    
    /// Fetch Video 获取视频，用于播放
    /// - Note: Only for `MediaType` Video 仅用于媒体类型为视频
    /// - Parameter options: Video Fetch Options 视频获取选项
    /// - Parameter completion: Video Fetch Completion 视频获取结果回调
    public func fetchVideo(options: VideoFetchOptions = .init(), completion: @escaping VideoFetchCompletion) {
        guard type == .video else {
            completion(.failure(.invalidMediaType))
            return
        }
        PhotoManager.shared.requestVideo(for: phAsset, options: options, completion: completion)
    }
    
    /// Fetch Video URL 获取视频路径，用于传输
    /// - Note: Only for `MediaType` Video 仅用于媒体类型为视频
    /// - Parameter options: Video URL Fetch Options 视频路径获取选项
    /// - Parameter completion: Video URL Fetch Completion 视频路径获取结果回调
    public func fetchVideoURL(options: VideoURLFetchOptions = .init(), completion: @escaping VideoURLFetchCompletion) {
        guard type == .video else {
            completion(.failure(.invalidMediaType))
            return
        }
        PhotoManager.shared.requestVideoURL(for: phAsset, options: options, completion: completion)
    }
}
