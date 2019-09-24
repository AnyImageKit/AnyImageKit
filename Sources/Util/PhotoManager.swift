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
    
    var sortAscendingByModificationDate: Bool = true
    var config = ImagePickerController.Config()
    
    var isSelectAll: Bool {
        return selectdAsset.count == config.maxCount
    }
    
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
    
    func readCache(for identifier: String) -> UIImage? {
        return cacheList.first(where: { $0.0 == identifier })?.1
    }
    
    private func writeCache(image: UIImage, for identifier: String) {
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
    
    func fetchCameraRollAlbum(allowPickingVideo: Bool, allowPickingImage: Bool, needFetchAssets: Bool, completion: @escaping (Album) -> Void) {
        let options = PHFetchOptions()
        if !allowPickingVideo {
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        if !allowPickingImage {
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if !sortAscendingByModificationDate {
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: sortAscendingByModificationDate)
            options.sortDescriptors = [sortDescriptor]
        }
        let assetCollectionsFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        let assetCollections = assetCollectionsFetchResult.objects()
        for assetCollection in assetCollections {
            if assetCollection.estimatedAssetCount <= 0 { continue }
            if assetCollection.isCameraRoll {
                let assetsfetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                let result = Album(result: assetsfetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: true, needFetchAssets: needFetchAssets)
                completion(result)
            }
        }
    }
    
    func fetchAllAlbums(allowPickingVideo: Bool, allowPickingImage: Bool, needFetchAssets: Bool, completion: @escaping ([Album]) -> Void) {
        workQueue.async {
            var results = [Album]()
            let options = PHFetchOptions()
            if !allowPickingVideo {
                options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
            }
            if !allowPickingImage {
                options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
            }
            if !self.sortAscendingByModificationDate {
                let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: self.sortAscendingByModificationDate)
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
                            let album = Album(result: assetFetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: true, needFetchAssets: needFetchAssets)
                            results.insert(album, at: 0)
                        }
                    } else {
                        if !results.contains(where: { $0.id == assetCollection.localIdentifier }) {
                            let album = Album(result: assetFetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: false, needFetchAssets: needFetchAssets)
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
    
    var sizeMode: SizeMode = .resize(100)
    var isNetworkAccessAllowed: Bool = true
    var progressHandler: PHAssetImageProgressHandler? = nil
    
    enum SizeMode: Equatable {
        
        case resize(CGFloat)
        case original
        
        var targetSize: CGSize {
            switch self {
            case .resize(let width):
                return CGSize(width: width, height: width)
            case .original:
                return PHImageManagerMaximumSize
            }
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
        if let asset = album.result.lastObject {
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
                    if !isDegraded {
                        self.writeCache(image: image, for: asset.localIdentifier)
                    }
                    completion(.success((image, isDegraded)))
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
            let options = PhotoFetchOptions(sizeMode: .original)
            self.requestImage(for: asset.asset, options: options) { _ in }
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
