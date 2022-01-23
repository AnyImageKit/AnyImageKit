//
//  Asset+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/23.
//  Copyright © 2021-2022 AnyImageProject.org. All rights reserved.
//

import Foundation
import Photos
import UIKit

typealias PhotoAsset = Asset<PHAsset>

extension PhotoAsset {
    
    init(phAsset: PHAsset, selectOption: PickerSelectOption, checker: AssetChecker<PHAsset>) {
        self.init(resource: phAsset,
                  mediaType: .photo,
                  checker: checker)
    }
    
    var phAsset: PHAsset {
        return resource
    }
}

extension PhotoAsset {
    
    var duration: TimeInterval {
        return phAsset.duration
    }
    
    var image: UIImage {
        return UIImage()
    }
    
    var durationDescription: String {
        let time = Int(duration)
        let min = time / 60
        let sec = time % 60
        return String(format: "%02ld:%02ld", min, sec)
    }
    
    var isReady: Bool {
        return true
    }
}

extension PhotoAsset: LoadableResource {

    public func loadImage(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        resource.loadPhotoLibraryImage(options: options)
    }

    public func loadImageData(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        resource.loadPhotoLibraryImageData(options: options)
    }

    public func loadLivePhoto(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        resource.loadPhotoLibraryLivePhoto(options: options)
    }

    public func loadGIF(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        resource.loadPhotoLibraryGIF(options: options)
    }

    public func loadVideo(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        resource.loadPhotoLibraryVideo(options: options)
    }
}
