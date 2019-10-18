//
//  PhotoManager+Album.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos

extension PhotoManager {
    
    func fetchCameraRollAlbum(completion: @escaping (Album) -> Void) {
        let options = PHFetchOptions()
        if !config.selectOptions.mediaTypes.contains(.video) {
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        if !config.selectOptions.mediaTypes.contains(.image) {
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
                let result = Album(result: assetsfetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: true, selectOptions: config.selectOptions)
                completion(result)
            }
        }
    }
    
    func fetchAllAlbums(completion: @escaping ([Album]) -> Void) {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            var results = [Album]()
            let options = PHFetchOptions()
            if !self.config.selectOptions.mediaTypes.contains(.video) {
                options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
            }
            if !self.config.selectOptions.mediaTypes.contains(.image) {
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
                            let album = Album(result: assetFetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: true, selectOptions: self.config.selectOptions)
                            results.insert(album, at: 0)
                        }
                    } else {
                        if !results.contains(where: { $0.id == assetCollection.localIdentifier }) {
                            let album = Album(result: assetFetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: false, selectOptions: self.config.selectOptions)
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
