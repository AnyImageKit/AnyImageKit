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
    
    /// 获取原图
    public func fetchPhotoData(options: PhotoDataFetchOptions = .init(), completion: @escaping PhotoDataFetchCompletion) {
        guard type == .photo || type == .photoGif else {
            completion(.failure(.invalidMediaType))
            return
        }
        PhotoManager.shared.requestPhotoData(for: phAsset, options: options, completion: completion)
    }
}

// MARK: - Video
extension Asset {
    
    /// 获取视频，用于播放
    public func fetchVideo(options: VideoFetchOptions = .init(), completion: @escaping VideoFetchCompletion) {
        guard type == .video else {
            completion(.failure(.invalidMediaType))
            return
        }
        PhotoManager.shared.requestVideo(for: phAsset, options: options, completion: completion)
    }
    
    /// 获取视频数据，用于传输
    public func fetchVideoData(options: VideoDataFetchOptions = .init(), completion: @escaping VideoDataFetchCompletion) {
        guard type == .video else {
            completion(.failure(.invalidMediaType))
            return
        }
        PhotoManager.shared.requestVideoData(for: phAsset, options: options, completion: completion)
    }
}
