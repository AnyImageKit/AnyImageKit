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
    func loadURL(handle: @escaping (Result<URL, Error>) -> Void)
}

extension URL: VideoResource {
    
    public func loadURL(handle: @escaping (Result<URL, Error>) -> Void) {
        handle(.success(self))
    }
}

extension PHAsset: VideoResource {
    
    public func loadURL(handle: @escaping (Result<URL, Error>) -> Void) {
        PHCachingImageManager().requestAVAsset(forVideo: self, options: nil) { (asset, audioMix, info) in
            if let avAsset = asset as? AVURLAsset {
                handle(.success(avAsset.url))
            } else {
                handle(.failure(ImageEditorError.fetchVideoUrlFailed))
            }
        }
    }
}
