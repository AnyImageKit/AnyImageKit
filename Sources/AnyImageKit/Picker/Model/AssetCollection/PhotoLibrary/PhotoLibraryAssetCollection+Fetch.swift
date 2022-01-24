//
//  PhotoLibraryAssetCollection+Fetch.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/19.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Photos

extension PhotoLibraryAssetCollection {
    
    @MainActor
    static func fetchDefault(options: PickerOptionsInfo) async -> PhotoLibraryAssetCollection {
        return await withCheckedContinuation { continuation in
            let fetchOptions = createFetchOptions(with: options)
            let collectionFetchResult = FetchResult(PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                                            subtype: .albumRegular,
                                                                                            options: nil))
            for assetCollection in collectionFetchResult {
                if assetCollection.estimatedAssetCount <= 0 { continue }
                if assetCollection.isUserLibrary {
                    let assetfetchResult = FetchResult(PHAsset.fetchAssets(in: assetCollection, options: fetchOptions))
                    let plugins = createCollectionPlugins(with: options, isUserLibrary: true)
                    let checker = AssetChecker<Resource>(limitCount: options.selectLimit,
                                                         preselectedIdentifiers: options.preselectAssets,
                                                         disableCheckRules: [])
                    let result = PhotoLibraryAssetCollection(identifier: assetCollection.localIdentifier,
                                                             localizedTitle: assetCollection.localizedTitle,
                                                             fetchResult: assetfetchResult,
                                                             fetchOrder: options.orderByDate,
                                                             isUserLibrary: true,
                                                             selectOption: options.selectOptions,
                                                             plugins: plugins,
                                                             checker: checker)
                    continuation.resume(returning: result)
                    return
                }
            }
        }
    }
    
    @MainActor
    static func fetchAll(options: PickerOptionsInfo) async -> [PhotoLibraryAssetCollection] {
        return await withCheckedContinuation { continuation in
            let phCollections = loadPHCollections(with: options)
            
            // Load Asset Collection
            var assetCollections = [PhotoLibraryAssetCollection]()
            let fetchOptions = createFetchOptions(with: options)
            
            for phCollection in phCollections {
                let isUserLibrary = phCollection.isUserLibrary
                
                if phCollection.estimatedAssetCount <= 0 && !isUserLibrary { continue }
                if phCollection.isAllHidden { continue }
                if phCollection.isRecentlyDeleted  { continue }
                
                let fetchResult = FetchResult(PHAsset.fetchAssets(in: phCollection, options: fetchOptions))
                if fetchResult.isEmpty && !isUserLibrary { continue }
                
                let plugins = createCollectionPlugins(with: options, isUserLibrary: isUserLibrary)
                let checker = AssetChecker<Resource>(limitCount: options.selectLimit,
                                                     preselectedIdentifiers: options.preselectAssets,
                                                     disableCheckRules: [])
                let assetCollection = PhotoLibraryAssetCollection(identifier: phCollection.localIdentifier,
                                                                  localizedTitle: phCollection.localizedTitle,
                                                                  fetchResult: fetchResult,
                                                                  fetchOrder: options.orderByDate,
                                                                  isUserLibrary: isUserLibrary,
                                                                  selectOption: options.selectOptions,
                                                                  plugins: plugins,
                                                                  checker: checker)
                if isUserLibrary {
                    assetCollections.insert(assetCollection, at: 0)
                } else {
                    assetCollections.append(assetCollection)
                }
            }
            
            continuation.resume(returning: assetCollections)
        }
    }
}

extension PhotoLibraryAssetCollection {
    
    private static func createFetchOptions(with options: PickerOptionsInfo) -> PHFetchOptions {
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
    
    private static func createCollectionPlugins(with options: PickerOptionsInfo, isUserLibrary: Bool) -> [AssetPlugin] {
        if !options.captureOptions.mediaOptions.isEmpty {
            return [.camera]
        } else {
            return []
        }
    }
    
    private static func loadPHCollections(with options: PickerOptionsInfo) -> [PHAssetCollection] {
        var phCollections: [PHAssetCollection] = []
        
        // Load Smart Albums
        if options.albumOptions.contains(.smart) {
            let subTypes: [PHAssetCollectionSubtype] = [.albumRegular,
                                                        .albumSyncedAlbum]
            let fetchResults = subTypes.map {
                FetchResult(PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: $0, options: nil))
            }
            for fetchResult in fetchResults {
                for phCollection in fetchResult {
                    if !phCollections.contains(where: { $0.localIdentifier == phCollection.localIdentifier}) {
                        phCollections.append(phCollection)
                    }
                }
            }
        }
        
        // Load User Albums
        if options.albumOptions.contains(.userCreated) {
            let fetchResult = FetchResult(PHCollectionList.fetchTopLevelUserCollections(with: nil))
            for phCollection in fetchResult.compactMap({ $0 as? PHAssetCollection }) {
                if !phCollections.contains(where: { $0.localIdentifier == phCollection.localIdentifier}) {
                    phCollections.append(phCollection)
                }
            }
        }
        
        // Load Shared Albums
        if options.albumOptions.contains(.shared) {
            let subTypes: [PHAssetCollectionSubtype] = [.albumMyPhotoStream,
                                                        .albumCloudShared]
            let fetchResults = subTypes.map {
                FetchResult(PHAssetCollection.fetchAssetCollections(with: .album, subtype: $0, options: nil))
            }
            for fetchResult in fetchResults {
                for phCollection in fetchResult {
                    if !phCollections.contains(where: { $0.localIdentifier == phCollection.localIdentifier}) {
                        phCollections.append(phCollection)
                    }
                }
            }
        }
        
        return phCollections
    }
}
