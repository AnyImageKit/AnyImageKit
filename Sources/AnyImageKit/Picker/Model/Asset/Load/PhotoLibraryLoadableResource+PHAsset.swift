//
//  PhotoLibraryLoadableResource+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos
import Kingfisher
import AVFoundation
import CoreServices

extension PHAsset: PhotoLibraryLoadableResource {
    
    func loadPhotoLibraryImage(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        return AsyncThrowingStream { continuation in
            let imageOptions = PHImageRequestOptions()
            imageOptions.version = .current
            imageOptions.resizeMode = .fast
            imageOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
            imageOptions.isSynchronous = false
            
            let imageID = PHImageManager.default().requestImage(for: self, targetSize: options.targetSize, contentMode: options.contentMode.phImageContentMode, options: imageOptions) { (image, info) in
                guard let info = info else {
                    continuation.finish(throwing: AnyImageError.invalidData)
                    return
                }
                
                if let image = image, let isDegraded = info[PHImageResultIsDegradedKey] as? Bool {
                    if isDegraded {
                        continuation.yield(.success(.thumbnail(image)))
                    } else {
                        continuation.yield(.success(.preview(image)))
                        continuation.finish()
                    }
                } else if let isInCloud = info[PHImageResultIsInCloudKey] as? Bool {
                    if isInCloud {
                        let task = Task {
                            let results = self.loadPhotoLibraryImageData(options: options)
                            for try await result in results {
                                if Task.isCancelled {
                                    continuation.finish(throwing: CancellationError())
                                } else {
                                    continuation.yield(result)
                                }
                            }
                        }
                        let id = info[PHImageResultRequestIDKey] as? PHImageRequestID
                        continuation.onTermination = { @Sendable termination in
                            switch termination {
                            case .cancelled:
                                PHImageManager.default().cancelImageRequest(id ?? 0)
                                task.cancel()
                            default:
                                break
                            }
                        }
                    } else {
                        continuation.finish(throwing: AnyImageError.invalidImage)
                    }
                } else if let error = info[PHImageErrorKey] as? Error {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { @Sendable termination in
                switch termination {
                case .cancelled:
                    PHImageManager.default().cancelImageRequest(imageID)
                case .finished(_):
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func loadPhotoLibraryImageData(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        return AsyncThrowingStream { continuation in
            let imageOptions = PHImageRequestOptions()
            imageOptions.version = .current
            imageOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
            imageOptions.isSynchronous = false
            imageOptions.progressHandler = { (progress, _, _, _) in
                continuation.yield(.progress(progress))
            }
            
            let imageID = PHImageManager.default().requestImageDataAndOrientation(for: self, options: imageOptions) { (data, dataUTI, orientation, info) in
                guard let info = info else {
                    continuation.finish(throwing: AnyImageError.invalidData)
                    return
                }
                
                if let data = data, let dataUTI = dataUTI {
                    continuation.yield(.success(.original(data: data, dataUTI: dataUTI, orientation: orientation)))
                    continuation.finish()
                } else if let error = info[PHImageErrorKey] as? Error {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { @Sendable termination in
                switch termination {
                case .cancelled:
                    PHImageManager.default().cancelImageRequest(imageID)
                case .finished(_):
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func loadPhotoLibraryLivePhoto(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        return AsyncThrowingStream { continuation in
            let livePhotoOptions = PHLivePhotoRequestOptions()
            livePhotoOptions.version = .current
            livePhotoOptions.deliveryMode = .highQualityFormat
            livePhotoOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
            livePhotoOptions.progressHandler = { (progress, _, _, _) in
                continuation.yield(.progress(progress))
            }
            
            let livePhotoID = PHImageManager.default().requestLivePhoto(for: self, targetSize: options.targetSize, contentMode: options.contentMode.phImageContentMode, options: livePhotoOptions) { (livePhoto, info) in
                guard let info = info else {
                    continuation.finish(throwing: AnyImageError.invalidData)
                    return
                }
                
                if let livePhoto = livePhoto {
                    continuation.yield(.success(.livePhoto(livePhoto)))
                    continuation.finish()
                } else if let error = info[PHImageErrorKey] as? Error {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { @Sendable termination in
                switch termination {
                case .cancelled:
                    PHImageManager.default().cancelImageRequest(livePhotoID)
                case .finished(_):
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func loadPhotoLibraryGIF(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                for try await result in loadPhotoLibraryImageData(options: options) {
                    guard !Task.isCancelled else { return }
                    switch result {
                    case .progress(let progress):
                        continuation.yield(.progress(progress))
                    case .success(let loadResult):
                        switch loadResult {
                        case .thumbnail(let image):
                            continuation.yield(.success(.thumbnail(image)))
                        case .preview(let image):
                            continuation.yield(.success(.preview(image)))
                        case .original(let data, let dataUTI, _):
                            guard UTTypeConformsTo(dataUTI as CFString, kUTTypeGIF) else {
                                continuation.finish(throwing: AnyImageError.invalidDataUTI)
                                return
                            }
                            guard let image = KingfisherWrapper<UIImage>.animatedImage(data: data, options: .init()) else {
                                continuation.finish(throwing: AnyImageError.invalidImage)
                                return
                            }
                            continuation.yield(.success(.gif(image)))
                        default:
                            break
                        }
                    }
                }
            }
            continuation.onTermination = { @Sendable termination in
                switch termination {
                case .cancelled:
                    task.cancel()
                case .finished(_):
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func loadPhotoLibraryVideo(options: ResourceLoadOptions) -> AsyncThrowingStream<LoadingResult<ResourceLoadResult>, Error>  {
        return AsyncThrowingStream { continuation in
            let videoOptions = PHVideoRequestOptions()
            videoOptions.version = .current
            videoOptions.isNetworkAccessAllowed = options.isNetworkAccessAllowed
            videoOptions.deliveryMode = .highQualityFormat
            videoOptions.progressHandler = { (progress, _, _, _) in
                continuation.yield(.progress(progress))
            }
            let videoID = PHImageManager.default().requestAVAsset(forVideo: self, options: videoOptions) { (avAsset, avAudioMix, info) in
                guard let info = info else {
                    continuation.finish(throwing: AnyImageError.invalidData)
                    return
                }
                
                if let avAsset = avAsset, let avAudioMix = avAudioMix {
                    continuation.yield(.success(.video(avAsset: avAsset, avAudioMix: avAudioMix)))
                    continuation.finish()
                } else if let error = info[PHImageErrorKey] as? Error {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { @Sendable termination in
                switch termination {
                case .cancelled:
                    PHImageManager.default().cancelImageRequest(videoID)
                case .finished(_):
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}
