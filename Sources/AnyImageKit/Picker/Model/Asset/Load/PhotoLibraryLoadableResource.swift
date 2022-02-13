//
//  PhotoLibraryLoadableResource.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos
import ImageIO
import AVFoundation

protocol PhotoLibraryLoadableResource {
    
    func loadPhotoLibraryImage(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error>
    func loadPhotoLibraryImageData(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error>
    func loadPhotoLibraryLivePhoto(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error>
    func loadPhotoLibraryGIF(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error>
    func loadPhotoLibraryVideo(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error>
}
