//
//  PickerManager+PhotoAssetCollection.swift
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
    
    func fetchCameraRollAlbum(completion: @escaping (PhotoAssetCollection) -> Void) {
        let fetchOptions = createFetchOptions()
        let assetCollectionsFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        let assetCollections = FetchResult(assetCollectionsFetchResult)
        for assetCollection in assetCollections {
            if assetCollection.estimatedAssetCount <= 0 { continue }
            if assetCollection.isUserLibrary {
                let assetsfetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                var additionOption: AssetCollectionAdditionOption = []
                #if ANYIMAGEKIT_ENABLE_CAPTURE
                if !options.captureOptions.mediaOptions.isEmpty {
                    additionOption.insert(.camera)
                }
                #endif
                let result = PhotoAssetCollection(identifier: assetCollection.localIdentifier,
                                                  localizedTitle: assetCollection.localizedTitle,
                                                  fetchResult: FetchResult(assetsfetchResult),
                                                  fetchOrder: options.orderByDate,
                                                  isUserLibrary: true,
                                                  additionOption: additionOption)
                result.fetchAssets(selectOptions: options.selectOptions)
                completion(result)
                return
            }
        }
    }
    
    func fetchAlbum(_ album: PhotoAssetCollection, completion: @escaping (PhotoAssetCollection) -> Void) {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            let fetchOptions = self.createFetchOptions()
            let assetCollectionsFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            let assetCollections = FetchResult(assetCollectionsFetchResult)
            for assetCollection in assetCollections {
                if assetCollection.estimatedAssetCount <= 0 { continue }
                if assetCollection.localIdentifier == album.identifier {
                    var additionOption: AssetCollectionAdditionOption = []
                    #if ANYIMAGEKIT_ENABLE_CAPTURE
                    if assetCollection.isUserLibrary && !self.options.captureOptions.mediaOptions.isEmpty {
                        additionOption.insert(.camera)
                    }
                    #endif
                    let assetsfetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                    let result = PhotoAssetCollection(identifier: assetCollection.localIdentifier,
                                                      localizedTitle: assetCollection.localizedTitle,
                                                      fetchResult: FetchResult(assetsfetchResult),
                                                      fetchOrder: self.options.orderByDate,
                                                      isUserLibrary: assetCollection.isUserLibrary,
                                                      additionOption: additionOption)
                    result.fetchAssets(selectOptions: self.options.selectOptions)
                    DispatchQueue.main.async {
                        completion(result)
                        return
                    }
                }
            }
        }
    }
    
    func fetchAllAlbums(completion: @escaping ([PhotoAssetCollection]) -> Void) {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            var results = [PhotoAssetCollection]()
            let options = self.createFetchOptions()
            
            func load(assetCollection: PHAssetCollection) {
                let isUserLibrary = assetCollection.isUserLibrary
                
                if assetCollection.estimatedAssetCount <= 0 && !isUserLibrary { return }
                
                if assetCollection.isAllHidden { return }
                if assetCollection.isRecentlyDeleted  { return }
                if results.contains(where: { assetCollection.localIdentifier == $0.identifier }) { return }
                
                let assetFetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                if assetFetchResult.count <= 0 && !isUserLibrary { return }
                
                if isUserLibrary {
                    var additionOption: AssetCollectionAdditionOption = []
                    #if ANYIMAGEKIT_ENABLE_CAPTURE
                    if !self.options.captureOptions.mediaOptions.isEmpty {
                        additionOption.insert(.camera)
                    }
                    #endif
                    let result = PhotoAssetCollection(identifier: assetCollection.localIdentifier,
                                                      localizedTitle: assetCollection.localizedTitle,
                                                      fetchResult: FetchResult(assetFetchResult),
                                                      fetchOrder: self.options.orderByDate,
                                                      isUserLibrary: isUserLibrary,
                                                      additionOption: additionOption)
                    result.fetchAssets(selectOptions: self.options.selectOptions)
                    results.insert(result, at: 0)
                } else {
                    let result = PhotoAssetCollection(identifier: assetCollection.localIdentifier,
                                                      localizedTitle: assetCollection.localizedTitle,
                                                      fetchResult: FetchResult(assetFetchResult),
                                                      fetchOrder: self.options.orderByDate,
                                                      isUserLibrary: isUserLibrary,
                                                      additionOption: [])
                    result.fetchAssets(selectOptions: self.options.selectOptions)
                    results.append(result)
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
                    let smartCollections = FetchResult(assetCollectionsFetchResult)
                    for assetCollection in smartCollections {
                        load(assetCollection: assetCollection)
                    }
                }
            }
            
            // Load User Albums
            if self.options.albumOptions.contains(.userCreated) {
                let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
                let userCollections = FetchResult(topLevelUserCollections).compactMap { $0 as? PHAssetCollection }
                for assetCollection in userCollections {
                    load(assetCollection: assetCollection)
                }
            }
            
            // Export results
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
}
