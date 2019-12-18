//
//  VideoResource.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/18.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

public protocol VideoResource {
    func loadURL(handler: @escaping (Result<URL, Error>) -> Void)
}

extension URL: VideoResource {
    
    public func loadURL(handler: @escaping (Result<URL, Error>) -> Void) {
        handler(.success(self))
    }
}

extension PHAsset: VideoResource {
    
    public func loadURL(handler: @escaping (Result<URL, Error>) -> Void) {
        guard mediaType == .video || mediaSubtypes == .photoLive else {
            handler(.failure(ImageEditorError.invalidMediaType))
            return
        }
        // Load from current device
        PHCachingImageManager().requestAVAsset(forVideo: self, options: nil) { (asset, audioMix, info) in
            if let avAsset = asset as? AVURLAsset {
                handler(.success(avAsset.url))
            } else {
                self.loadURLFromNetwork(handler: handler)
            }
        }
    }
    
    private func loadURLFromNetwork(handler: @escaping (Result<URL, Error>) -> Void) {
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .automatic
        PHImageManager.default().requestExportSession(forVideo: self, options: options, exportPreset: AVAssetExportPresetMediumQuality) { (exportSession, info) in
            
        }
        
        
        
//        let assetResources = PHAssetResource.assetResources(for: self)
//        guard let resource = (assetResources.filter{ $0.type == .video || $0.type == .pairedVideo }.first) else {
//            handler(.failure(ImageEditorError.fetchVideoUrlFailed))
//            return
//        }
//
//        let fileName = resource.originalFilename
//        PHAssetResourceManager.default().writeData(for: resource, toFile: URL(fileURLWithPath: ""), options: nil) { (error) in
//            if let error = error {
//                _print("Load asset failed: \(error.localizedDescription)")
//                handler(.failure(ImageEditorError.fetchVideoUrlFailed))
//            } else {
//                handler(.success(<#T##URL#>))
//            }
//        }
    }
}
