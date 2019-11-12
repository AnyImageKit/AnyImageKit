//
//  Asset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

public class Asset: Equatable {
    /// 对应的 PHAsset
    public let phAsset: PHAsset
    /// 媒体类型
    public let mediaType: MediaType
    /// 输出图像
    public var image: UIImage {
        return _image ?? .init()
    }
    
    var _image: UIImage?
    var videoDidDownload: Bool = false
    
    var idx: Int
    let videoDuration: String
    var isSelected: Bool = false
    var selectedNum: Int = 1
    
    init(idx: Int, asset: PHAsset, selectOptions: ImagePickerController.SelectOptions) {
        self.idx = idx
        self.phAsset = asset
        self.mediaType = MediaType(asset: asset, selectOptions: selectOptions)
        self.videoDuration = asset.videoDuration
    }
    
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.phAsset.localIdentifier == rhs.phAsset.localIdentifier
    }
}

extension Asset: CustomStringConvertible {
    
    public var description: String {
        return "<Asset> \(phAsset.localIdentifier) mediaType=\(mediaType) image=\(image)"
    }
}

extension Asset {
    var isCamera: Bool {
        return idx == -1
    }
}

// MARK: - Original Photo
extension Asset {
    
    /// Fetch Photo Data 获取原图数据
    /// - Note: Only for `MediaType` Photo, GIF, LivePhoto 仅用于媒体类型为照片、GIF、实况
    /// - Parameter options: Photo Data Fetch Options 原图获取选项
    /// - Parameter completion: Photo Data Fetch Completion 原图获取结果回调
    public func fetchPhotoData(options: PhotoDataFetchOptions = .init(), completion: @escaping PhotoDataFetchCompletion) {
        guard phAsset.mediaType == .image else {
            completion(.failure(.invalidMediaType))
            return
        }
        PickerManager.shared.requestPhotoData(for: phAsset, options: options, completion: completion)
    }
    
    /// Fetch Photo URL 获取原图路径
    /// - Note: Only for `MediaType` Photo, PhotoGIF 仅用于媒体类型为照片、GIF
    /// - Parameter options: Photo URL Fetch Options 原图路径获取选项
    /// - Parameter completion: Photo URL Fetch Completion 原图路径获取结果回调
    public func fetchPhotoURL(options: PhotoURLFetchOptions = .init(), completion: @escaping PhotoURLFetchCompletion) {
        guard phAsset.mediaType == .image else {
            completion(.failure(.invalidMediaType))
            return
        }
        PickerManager.shared.requestPhotoURL(for: phAsset, options: options, completion: completion)
    }
}

// MARK: - Video
extension Asset {
    
    /// Fetch Video 获取视频，用于播放
    /// - Note: Only for `MediaType` Video 仅用于媒体类型为视频
    /// - Parameter options: Video Fetch Options 视频获取选项
    /// - Parameter completion: Video Fetch Completion 视频获取结果回调
    public func fetchVideo(options: VideoFetchOptions = .init(), completion: @escaping VideoFetchCompletion) {
        guard phAsset.mediaType == .video else {
            completion(.failure(.invalidMediaType))
            return
        }
        PickerManager.shared.requestVideo(for: phAsset, options: options, completion: completion)
    }
    
    /// Fetch Video URL 获取视频路径，用于传输
    /// - Note: Only for `MediaType` Video 仅用于媒体类型为视频
    /// - Parameter options: Video URL Fetch Options 视频路径获取选项
    /// - Parameter completion: Video URL Fetch Completion 视频路径获取结果回调
    public func fetchVideoURL(options: VideoURLFetchOptions = .init(), completion: @escaping VideoURLFetchCompletion) {
        guard phAsset.mediaType == .video else {
            completion(.failure(.invalidMediaType))
            return
        }
        PickerManager.shared.requestVideoURL(for: phAsset, options: options, completion: completion)
    }
}

extension Asset {
    
    var isReady: Bool {
        switch mediaType {
        case .photo, .photoGIF, .photoLive:
            return _image != nil
        case .video:
            return videoDidDownload
        }
    }
}
