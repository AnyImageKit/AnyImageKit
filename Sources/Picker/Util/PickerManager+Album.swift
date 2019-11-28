//
//  PickerManager+Album.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Photos

extension PickerManager {
    
    private func createFetchOptions() -> PHFetchOptions {
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
        return options
    }
    
    func fetchCameraRollAlbum(completion: @escaping (Album) -> Void) {
        let options = createFetchOptions()
        let assetCollectionsFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        let assetCollections = assetCollectionsFetchResult.objects()
        for assetCollection in assetCollections {
            if assetCollection.estimatedAssetCount <= 0 { continue }
            if assetCollection.isCameraRoll {
                let assetsfetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                let result = Album(result: assetsfetchResult, id: assetCollection.localIdentifier, name: assetCollection.localizedTitle, isCameraRoll: true, selectOptions: config.selectOptions)
                completion(result)
                return
            }
        }
    }
    
    func fetchAllAlbums(completion: @escaping ([Album]) -> Void) {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            var results = [Album]()
            let options = self.createFetchOptions()
            
            func load(assetCollections: [PHAssetCollection]) {
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
            
            // Load Smart Albums
            if self.config.albumOptions.contains(.smart) {
                let allAlbumSubTypes: [PHAssetCollectionSubtype] = [.albumMyPhotoStream,
                                                                    .albumRegular,
                                                                    .albumSyncedAlbum,
                                                                    .albumCloudShared]
                let assetCollectionsfetchResults = allAlbumSubTypes.map { PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: $0, options: nil) }
                for assetCollectionsFetchResult in assetCollectionsfetchResults {
                    let smartCollections = assetCollectionsFetchResult.objects()
                    load(assetCollections: smartCollections)
                }
            }
            
            // Load User Albums
            if self.config.albumOptions.contains(.userCreated) {
                let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
                let userCollections = topLevelUserCollections.objects().compactMap { $0 as? PHAssetCollection }
                load(assetCollections: userCollections)
            }
            
            // Export results
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
}
