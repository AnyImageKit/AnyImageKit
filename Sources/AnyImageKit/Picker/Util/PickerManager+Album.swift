//
//  PickerManager+Album.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import Photos

extension PickerManager {
    
    private func createFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        if !options.selectOptions.mediaTypes.contains(.video) {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        if !options.selectOptions.mediaTypes.contains(.image) {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        if options.orderByDate == .desc {
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchOptions.sortDescriptors = [sortDescriptor]
        }
        return fetchOptions
    }
    
    func fetchCameraRollAlbum(completion: @escaping (Album) -> Void) {
        let fetchOptions = createFetchOptions()
        let assetCollectionsFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        let assetCollections = assetCollectionsFetchResult.objects()
        for assetCollection in assetCollections {
            if assetCollection.estimatedAssetCount <= 0 { continue }
            if assetCollection.isCameraRoll {
                let assetsfetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                let result = Album(fetchResult: assetsfetchResult,
                                   identifier: assetCollection.localIdentifier,
                                   title: assetCollection.localizedTitle,
                                   isCameraRoll: true,
                                   selectOptions: options.selectOptions)
                completion(result)
                return
            }
        }
    }
    
    func fetchAlbum(_ album: Album, completion: @escaping (Album) -> Void) {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            let fetchOptions = self.createFetchOptions()
            let assetCollectionsFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            let assetCollections = assetCollectionsFetchResult.objects()
            for assetCollection in assetCollections {
                if assetCollection.estimatedAssetCount <= 0 { continue }
                if assetCollection.localIdentifier == album.identifier {
                    let assetsfetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                    let result = Album(fetchResult: assetsfetchResult,
                                       identifier: assetCollection.localIdentifier,
                                       title: assetCollection.localizedTitle,
                                       isCameraRoll: assetCollection.isCameraRoll,
                                       selectOptions: self.options.selectOptions)
                    DispatchQueue.main.async {
                        completion(result)
                        return
                    }
                }
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
                    if results.contains(where: { assetCollection.localIdentifier == $0.identifier }) { continue }
                    
                    let assetFetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                    if assetFetchResult.count <= 0 && !isCameraRoll { continue }
                    
                    if isCameraRoll {
                        let result = Album(fetchResult: assetFetchResult,
                                           identifier: assetCollection.localIdentifier,
                                           title: assetCollection.localizedTitle,
                                           isCameraRoll: true,
                                           selectOptions: self.options.selectOptions)
                        results.insert(result, at: 0)
                    } else {
                        let result = Album(fetchResult: assetFetchResult,
                                           identifier: assetCollection.localIdentifier,
                                           title: assetCollection.localizedTitle,
                                           isCameraRoll: false,
                                           selectOptions: self.options.selectOptions)
                        results.append(result)
                    }
                }
            }
            
            // Load Smart Albums
            if self.options.albumOptions.contains(.smart) {
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
            if self.options.albumOptions.contains(.userCreated) {
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
