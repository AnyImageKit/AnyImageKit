//
//  LoadableResource+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/25.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Photos

extension PHAsset: LoadableResource {
    
    func loadImage(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        loadPhotoLibraryImage(options: options)
    }
    
    func loadImageData(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        loadPhotoLibraryImageData(options: options)
    }
    
    func loadLivePhoto(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        loadPhotoLibraryLivePhoto(options: options)
    }
    
    func loadGIF(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        loadPhotoLibraryGIF(options: options)
    }
    
    func loadVideo(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        loadPhotoLibraryVideo(options: options)
    }
}
