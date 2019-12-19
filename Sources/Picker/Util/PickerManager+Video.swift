//
//  PickerManager+Video.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/29.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Photos

typealias _VideoFetchCompletion = (Result<VideoFetchResponse, ImageKitError>) -> Void
typealias _VideoURLFetchCompletion = (Result<VideoURLFetchResponse, ImageKitError>) -> Void

extension PickerManager {
    
    func requestVideo(for asset: PHAsset, options: VideoFetchOptions = .init(), completion: @escaping _VideoFetchCompletion) {
        let requestID = ExportTool.requestVideo(for: asset, options: options) { (result, requestID) in
            completion(result)
            self.dequeueFetch(for: asset.localIdentifier, requestID: requestID)
        }
        enqueueFetch(for: asset.localIdentifier, requestID: requestID)
    }
    
    func saveVideo(at url: URL, completion: @escaping VideoSaveCompletion) {
        ExportTool.saveVideo(at: url, completion: completion)
    }
}
