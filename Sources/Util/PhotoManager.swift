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
    
    /// 已选中的资源
    private var selectdAsset: [Asset] = []
    
    /// 缓存
    private var cacheList = [(String, UIImage)]()
    
    private init() { }
    
    private let workQueue = DispatchQueue(label: "com.anotheren.AnyImagePicker.PhotoManager")
}

// MARK: - Cache

extension PhotoManager {
    
    func readCache(for identifier: String) -> UIImage? {
        return cacheList.first(where: { $0.0 == identifier })?.1
    }
    
    private func writeCache(image: UIImage, for identifier: String) {
        if cacheList.contains(where: { $0.0 == identifier }) {
            return
        }
        if cacheList.count > 9 { // TODO
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

// MARK: - Asset

extension PhotoManager {
    
    typealias PhotoFetchHander = (UIImage, [AnyHashable: Any], Bool) -> Void
    
    @discardableResult
    func requestImage(from album: Album, completion: @escaping PhotoFetchHander) -> PHImageRequestID {
        if let asset = album.result.lastObject {
            let sacle = UIScreen.main.nativeScale
            return requestImage(for: asset, width: 55*sacle, completion: completion)
        }
        return PHInvalidImageRequestID
    }
    
    @discardableResult
    func requestImage(for asset: PHAsset, width: CGFloat, isNetworkAccessAllowed: Bool = true, progressHandler: PHAssetImageProgressHandler? = nil, completion: @escaping PhotoFetchHander) -> PHImageRequestID {
        
        let options1 = PHImageRequestOptions()
        options1.resizeMode = .fast
        
        let targetSize = CGSize(width: width, height: width)
        let imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options1) { (image, info) in
            guard let info = info else { return }
            let isCancelled = info[PHImageCancelledKey] as? Bool ?? false
            let error = info[PHImageErrorKey] as? Error
            let isDegraded = info[PHImageResultIsDegradedKey] as? Bool ?? false
            
            let isDownload = !isCancelled && error == nil
            if isDownload, let image = image {
                let resizedImage = UIImage.resize(from: image, size: targetSize)
                completion(resizedImage, info, isDegraded)
            }
            
            // Download image from iCloud
            let isInCloud = info[PHImageResultIsInCloudKey] as? Bool ?? false
            if isInCloud && image == nil && isNetworkAccessAllowed {
                let options2 = PHImageRequestOptions()
                options2.progressHandler = progressHandler
                options2.isNetworkAccessAllowed = isNetworkAccessAllowed
                options2.resizeMode = .fast
                PHImageManager.default().requestImageData(for: asset, options: options2) { (data, uti, orientation, info) in
                    if let data = data, let info = info, let image = UIImage.resize(from: data, size: targetSize) {
                        completion(image, info, false)
                    }
                }
            }
        }
        return imageRequestID
    }
    
    //TODO
    @discardableResult
    func requestOriginalImage(for asset: PHAsset, isNetworkAccessAllowed: Bool = true, progressHandler: PHAssetImageProgressHandler? = nil, completion: @escaping PhotoFetchHander) -> PHImageRequestID {
        
        let options1 = PHImageRequestOptions()
        options1.resizeMode = .fast
        
        let targetSize = CGSize(width: 3000, height: 3000)
        let imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options1) { [weak self] (image, info) in
            guard let self = self else { return }
            guard let info = info else { return }
            let isCancelled = info[PHImageCancelledKey] as? Bool ?? false
            let error = info[PHImageErrorKey] as? Error
            let isDegraded = info[PHImageResultIsDegradedKey] as? Bool ?? false
            
            let isDownload = !isCancelled && error == nil
            if isDownload, let image = image {
                let resizedImage = UIImage.resize(from: image, size: targetSize)
                if !isDegraded {
                    self.writeCache(image: resizedImage, for: asset.localIdentifier)
                }
                completion(resizedImage, info, isDegraded)
            }
            
            // Download image from iCloud
            let isInCloud = info[PHImageResultIsInCloudKey] as? Bool ?? false
            if isInCloud && image == nil && isNetworkAccessAllowed {
                let options2 = PHImageRequestOptions()
                options2.progressHandler = progressHandler
                options2.isNetworkAccessAllowed = isNetworkAccessAllowed
                options2.resizeMode = .fast
                PHImageManager.default().requestImageData(for: asset, options: options2) { (data, uti, orientation, info) in
                    if let data = data, let info = info, let image = UIImage.resize(from: data, size: targetSize) {
                        completion(image, info, false)
                    }
                }
            }
        }
        return imageRequestID
    }
}

extension PhotoManager {
    
    public func addSelectedAsset(_ asset: Asset) {
        selectdAsset.append(asset)
        asset.selectedNum = selectdAsset.count
        NotificationCenter.default.post(name: .didUpdateSelectedAsset, object: nil)
    }
    
    public func removeSelectedAsset(_ asset: Asset) {
        guard let idx = PhotoManager.shared.selectdAsset.firstIndex(where: { $0 == asset }) else { return }
        for item in selectdAsset {
            if item.selectedNum > asset.selectedNum {
                item.selectedNum -= 1
            }
        }
        selectdAsset.remove(at: idx)
        NotificationCenter.default.post(name: .didUpdateSelectedAsset, object: nil)
    }
    
    public func removeAllSelectedAsset() {
        selectdAsset.removeAll()
    }
}


extension Notification.Name {
    
    static let didUpdateSelectedAsset = Notification.Name("com.anotheren.AnyImagePicker.didUpdateSelectedAsset")
    
}
