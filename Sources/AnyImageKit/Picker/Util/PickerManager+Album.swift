//
//  PickerManager+Album.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos

extension PickerManager {
    
    private func createFetchOptions(filter: PickerMediaTypeFilter = .all,
                                    displaySort: Album.DisplaySort = .recentlyAdded) -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        let mediaTypes: [PHAssetMediaType]
        switch filter {
        case .photo:
            mediaTypes = [.image]
        case .video:
            mediaTypes = [.video]
        default:
            mediaTypes = options.selectOptions.mediaTypes
        }
        if mediaTypes.count == 1, let mediaType = mediaTypes.first {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", mediaType.rawValue)
        }
        if displaySort == .capturedDate {
            // Album applies the configured ascending/descending direction lazily.
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        }
        return fetchOptions
    }
    
    func fetchCameraRollAlbum(completion: @escaping (Album) -> Void) {
        workQueue.async { [weak self] in
            guard let self else { return }
            let fetchOptions = self.createFetchOptions()
#if compiler(>=6)
            let assetCollectionsFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
#else
            let assetCollectionsFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
#endif
            let assetCollections = assetCollectionsFetchResult.objects()
            for assetCollection in assetCollections {
                if assetCollection.estimatedAssetCount <= 0 { continue }
                if assetCollection.isCameraRoll {
                    let assetsFetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                    let result = Album(fetchResult: assetsFetchResult,
                                       identifier: assetCollection.localIdentifier,
                                       title: assetCollection.localizedTitle,
                                       isCameraRoll: true,
                                       selectOptions: self.options.selectOptions,
                                       sort: self.options.orderByDate)
                    DispatchQueue.main.async {
                        completion(result)
                    }
                    return
                }
            }
        }
    }
    
    func fetchAlbum(_ album: Album,
                    filter: PickerMediaTypeFilter,
                    displaySort: Album.DisplaySort,
                    completion: @escaping (Album) -> Void) {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            let fetchOptions = self.createFetchOptions(filter: filter, displaySort: displaySort)
            let result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [album.identifier], options: nil)
            guard let assetCollection = result.firstObject else { return }
            let assetsFetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            let newAlbum = Album(fetchResult: assetsFetchResult,
                                 identifier: assetCollection.localIdentifier,
                                 title: assetCollection.localizedTitle,
                                 isCameraRoll: assetCollection.isCameraRoll,
                                 selectOptions: self.options.selectOptions,
                                 sort: self.options.orderByDate,
                                 filter: filter,
                                 displaySort: displaySort)
            DispatchQueue.main.async {
                completion(newAlbum)
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
                                           selectOptions: self.options.selectOptions,
                                           sort: self.options.orderByDate)
                        results.insert(result, at: 0)
                    } else {
                        let result = Album(fetchResult: assetFetchResult,
                                           identifier: assetCollection.localIdentifier,
                                           title: assetCollection.localizedTitle,
                                           isCameraRoll: false,
                                           selectOptions: self.options.selectOptions,
                                           sort: self.options.orderByDate)
                        results.append(result)
                    }
                }
            }
            
            // Load Smart Albums
            if self.options.albumOptions.contains(.smart) {
#if compiler(>=6)
                let subTypes: [PHAssetCollectionSubtype] = [.albumRegular,
                                                            .albumSyncedAlbum,
                                                            .any]
#else
                let subTypes: [PHAssetCollectionSubtype] = [.albumRegular,
                                                            .albumSyncedAlbum]
#endif
                
                let assetCollectionsFetchResults = subTypes.map {
                    PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: $0, options: nil)
                }
                for assetCollectionsFetchResult in assetCollectionsFetchResults {
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
            
            // Load Shared Albums
            if self.options.albumOptions.contains(.shared) {
#if compiler(>=6)
                let subTypes: [PHAssetCollectionSubtype] = [.albumMyPhotoStream,
                                                            .albumCloudShared,
                                                            .any]
#else
                let subTypes: [PHAssetCollectionSubtype] = [.albumMyPhotoStream,
                                                            .albumCloudShared]
#endif
                let assetCollectionsFetchResults = subTypes.map {
                    PHAssetCollection.fetchAssetCollections(with: .album, subtype: $0, options: nil)
                }
                for assetCollectionsFetchResult in assetCollectionsFetchResults {
                    let smartCollections = assetCollectionsFetchResult.objects()
                    load(assetCollections: smartCollections)
                }
            }
            
            // Export results
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
}
