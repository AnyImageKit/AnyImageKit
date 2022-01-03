//
//  PickerManager+Video.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/29.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos

typealias _VideoFetchCompletion = (Result<VideoFetchResponse, AnyImageError>) -> Void
typealias _VideoURLFetchCompletion = (Result<VideoURLFetchResponse, AnyImageError>) -> Void

extension PickerManager {
    
    func requestVideo(for asset: PHAsset, options: VideoFetchOptions = .init(), completion: @escaping _VideoFetchCompletion) {
        let requestID = ExportTool.requestVideo(for: asset, options: options) { (result, requestID) in
            completion(result)
            self.dequeueFetch(for: asset.localIdentifier, requestID: requestID)
        }
        enqueueFetch(for: asset.localIdentifier, requestID: requestID)
    }
    
    func saveVideo(url: URL, completion: @escaping VideoSaveCompletion) {
        ExportTool.saveVideo(url, completion: completion)
    }
}
