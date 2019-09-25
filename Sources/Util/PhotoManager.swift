//
//  PhotoManager.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import Photos

final class PhotoManager {
    
    static let shared: PhotoManager = PhotoManager()
    
    var config = ImagePickerController.Config()
    
    var isMaxCount: Bool {
        return selectdAsset.count == config.maxCount
    }
    
    var isOriginalPhoto: Bool = false
    
    /// 已选中的资源
    private(set) var selectdAsset: [Asset] = []
    
    /// 缓存
    private var cacheList = [(String, UIImage)]()
    
    private init() { }
    
    private let workQueue = DispatchQueue(label: "com.anotheren.AnyImagePicker.PhotoManager")
}

// MARK: - Cache

extension PhotoManager {
    
    func clearCache() {
        cacheList.removeAll()
    }
    
    private func removeCache(for identifier: String) {
        if let index = cacheList.firstIndex(where: { $0.0 == identifier }) {
            cacheList.remove(at: index)
        }
    }
    
    func readCache(for identifier: String) -> UIImage? {
        return cacheList.first(where: { $0.0 == identifier })?.1
    }
    
    func writeCache(image: UIImage, for identifier: String) {
        if cacheList.contains(where: { $0.0 == identifier }) {
            return
        }
        if cacheList.count > PhotoManager.shared.config.maxCount {
            cacheList.removeFirst()
        }
        cacheList.append((identifier, image))
    }
}

// MARK: - Album

extension PhotoManager {
    
    func fetchCameraRollAlbum(completion: @escaping (Album) -> Void) {
        let options = PHFetchOptions()
        if !config.selectOptions.contains(.video) {
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        if !config.selectOptions.contains(.photo) {
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if config.orderByDate == .desc {
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            options.sortDescriptors = [sortDescriptor]
        }
        let assetCollectionsFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        let assetCollections = assetCollectionsFetchResult.objects()
        for assetCollection in assetCollections {
            if assetCollection.estimatedAssetCount <= 0 { continue }
            if assetCollection.isCameraRoll {
                let assetsfetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                let result = Album(result: assetsfetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: true, needFetchAssets: true)
                completion(result)
            }
        }
    }
    
    func fetchAllAlbums(completion: @escaping ([Album]) -> Void) {
        workQueue.async {
            var results = [Album]()
            let options = PHFetchOptions()
            if !self.config.selectOptions.contains(.video) {
                options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
            }
            if !self.config.selectOptions.contains(.photo) {
                options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
            }
            if self.config.orderByDate == .desc {
                let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
                options.sortDescriptors = [sortDescriptor]
            }
            
            let allAlbumSubTypes: [PHAssetCollectionSubtype] = [.albumMyPhotoStream, .albumRegular, .albumSyncedAlbum, .albumCloudShared]
            let assetCollectionsfetchResults = allAlbumSubTypes.map { PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: $0, options: nil) }
            for assetCollectionsFetchResult in assetCollectionsfetchResults {
                let assetCollections = assetCollectionsFetchResult.objects()
                for assetCollection in assetCollections {
                    let isCameraRoll = assetCollection.isCameraRoll
                    
                    if assetCollection.estimatedAssetCount <= 0 && !isCameraRoll { continue }
                    
                    if assetCollection.isAllHidden { continue }
                    if assetCollection.isRecentlyDeleted  { continue }
                    
                    let assetFetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                    if assetFetchResult.count <= 0 && !isCameraRoll { continue }
                    
                    if isCameraRoll {
                        if !results.contains(where: { $0.id == assetCollection.localIdentifier }) {
                            let album = Album(result: assetFetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: true, needFetchAssets: true)
                            results.insert(album, at: 0)
                        }
                    } else {
                        if !results.contains(where: { $0.id == assetCollection.localIdentifier }) {
                            let album = Album(result: assetFetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: false, needFetchAssets: true)
                            results.append(album)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
}

struct PhotoFetchOptions {
    
    var sizeMode: PhotoSizeMode = .resize(100)
    var isNetworkAccessAllowed: Bool = true
    var progressHandler: PHAssetImageProgressHandler? = nil
}

enum PhotoSizeMode: Equatable {
    
    case resize(CGFloat)
    case preview
    case original
    
    var targetSize: CGSize {
        switch self {
        case .resize(let width):
            return CGSize(width: width, height: width)
        case .preview:
            let width = UIScreen.main.bounds.width
            let scale = UIScreen.main.nativeScale
            let screenWidth = width * scale
            return CGSize(width: screenWidth, height: screenWidth)
        case .original:
            return PHImageManagerMaximumSize
        }
    }
}

enum ImagePickerError: Error {
    
    case invalidInfo
    case invalidData
    case other(Error)
}

typealias PhotoFetchResponse = (image: UIImage, isDegraded: Bool)
typealias PhotoFetchCompletion = (Result<PhotoFetchResponse, ImagePickerError>) -> Void

// MARK: - Asset

extension PhotoManager {
    
    @discardableResult
    func requestImage(from album: Album, completion: @escaping PhotoFetchCompletion) -> PHImageRequestID {
        if let asset = config.orderByDate == .asc ? album.result.lastObject : album.result.firstObject {
            let sacle = UIScreen.main.nativeScale
            let options = PhotoFetchOptions(sizeMode: .resize(55*sacle))
            return requestImage(for: asset, options: options, completion: completion)
        }
        return PHInvalidImageRequestID
    }
    
    @discardableResult
    func requestImage(for asset: PHAsset, options: PhotoFetchOptions = .init(), completion: @escaping PhotoFetchCompletion) -> PHImageRequestID {
        let requestOptions1 = PHImageRequestOptions()
        requestOptions1.resizeMode = .fast
        let imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: options.sizeMode.targetSize, contentMode: .aspectFill, options: requestOptions1) { (image, info) in
            guard let info = info else {
                completion(.failure(.invalidInfo))
                return
            }
            let isCancelled = info[PHImageCancelledKey] as? Bool ?? false
            let error = info[PHImageErrorKey] as? Error
            let isDegraded = info[PHImageResultIsDegradedKey] as? Bool ?? false
            let isDownload = !isCancelled && error == nil
            if isDownload, let image = image {
                switch options.sizeMode {
                case .original:
                    completion(.success((image, isDegraded)))
                case .preview:
                    let resizedImage = UIImage.resize(from: image, size: options.sizeMode.targetSize)
                    if !isDegraded {
                        self.writeCache(image: image, for: asset.localIdentifier)
                    }
                    completion(.success((resizedImage, isDegraded)))
                case .resize:
                    let resizedImage = UIImage.resize(from: image, size: options.sizeMode.targetSize)
                    completion(.success((resizedImage, isDegraded)))
                }
            } else {
                // Download image from iCloud
                print("Download image from iCloud")
                let isInCloud = info[PHImageResultIsInCloudKey] as? Bool ?? false
                if isInCloud && image == nil && options.isNetworkAccessAllowed {
                    let requestOptions2 = PHImageRequestOptions()
                    requestOptions2.progressHandler = options.progressHandler
                    requestOptions2.isNetworkAccessAllowed = options.isNetworkAccessAllowed
                    requestOptions2.resizeMode = .fast
                    PHImageManager.default().requestImageData(for: asset, options: requestOptions2) { (data, uti, orientation, info) in
                        guard let data = data else {
                            completion(.failure(.invalidData))
                            return
                        }
                        switch options.sizeMode {
                        case .original:
                            guard let image = UIImage(data: data) else {
                                completion(.failure(.invalidData))
                                return
                            }
                            completion(.success((image, false)))
                        case .preview:
                            guard let image = UIImage.resize(from: data, size: options.sizeMode.targetSize) else {
                                completion(.failure(.invalidData))
                                return
                            }
                            self.writeCache(image: image, for: asset.localIdentifier)
                            completion(.success((image, false)))
                        case .resize:
                            guard let image = UIImage.resize(from: data, size: options.sizeMode.targetSize) else {
                                completion(.failure(.invalidData))
                                return
                            }
                            completion(.success((image, false)))
                        }
                    }
                }
            }
        }
        return imageRequestID
    }
}

enum DataUTI {
    
    case jpeg
    case png
    case gif
    case heif
    case mp4
    case mov
    case other(String)
}

struct DataFetchOptions {
    
    var isNetworkAccessAllowed: Bool = true
    var progressHandler: PHAssetImageProgressHandler? = nil
}


typealias DataFetchResponse = (data: Data, uti: DataUTI, url: URL)
typealias DataFetchCompletion = (Result<DataFetchResponse, ImagePickerError>) -> Void

extension PhotoManager {
    
    func requestData(for asset: PHAsset, options: DataFetchOptions = .init(), completion: @escaping PhotoFetchCompletion) {
        
        
    }
}

extension PhotoManager {
    
    public func addSelectedAsset(_ asset: Asset) {
        selectdAsset.append(asset)
        asset.selectedNum = selectdAsset.count
        // 加载原图，缓存到内存
        workQueue.async { [weak self] in
            guard let self = self else { return }
            let options = PhotoFetchOptions(sizeMode: .preview)
            self.requestImage(for: asset.asset, options: options) { result in
                switch result {
                case .success(let response):
                    if !response.isDegraded {
                        let options2 = PhotoFetchOptions(sizeMode: .original)
                        self.requestImage(for: asset.asset, options: options2) { _ in }
                    }
                case .failure:
                    break
                }
            }
        }
    }
    
    public func removeSelectedAsset(_ asset: Asset) {
        guard let idx = PhotoManager.shared.selectdAsset.firstIndex(where: { $0 == asset }) else { return }
        for item in selectdAsset {
            if item.selectedNum > asset.selectedNum {
                item.selectedNum -= 1
            }
        }
        selectdAsset.remove(at: idx)
    }
    
    public func removeAllSelectedAsset() {
        selectdAsset.removeAll()
    }
}
