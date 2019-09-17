//
//  PhotoManager.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos

final class PhotoManager {
    
    static let shared: PhotoManager = PhotoManager()
    
    var sortAscendingByModificationDate: Bool = true

    private init() { }
}

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
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: options)
        let smartAlbums = fetchResult.objects()
        for smartAlbum in smartAlbums {
            if smartAlbum.estimatedAssetCount <= 0 { continue }
            if smartAlbum.isCameraRoll {
                let result = Album(result: fetchResult, id: smartAlbum.localIdentifier, name: smartAlbum.localizedTitle, isCameraRoll: true, needFetchAssets: needFetchAssets)
                completion(result)
            }
        }
    }
    
    func fetchAllAlbums(allowPickingVideo: Bool, allowPickingImage: Bool, needFetchAssets: Bool, completion: @escaping ([Album]) -> Void) {
        var results = [Album]()
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
        
        let allAlbumSubTypes: [PHAssetCollectionSubtype] = [.albumMyPhotoStream, .albumRegular, .albumSyncedAlbum, .albumCloudShared]
        let fetchResults = allAlbumSubTypes.map { PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: $0, options: nil) }
        for fetchResult in fetchResults {
            let smartAlbums = fetchResult.objects()
            for smartAlbum in smartAlbums {
                if smartAlbum.estimatedAssetCount <= 0 && !smartAlbum.isCameraRoll { continue }
                let assetFetchResult = PHAsset.fetchAssets(in: smartAlbum, options: options)
                if assetFetchResult.count <= 0 && !smartAlbum.isCameraRoll { continue }
                
                if smartAlbum.isAllHidden { continue }
                if smartAlbum.isRecentlyDeleted  { continue }
                
                if smartAlbum.isCameraRoll {
                    if !results.contains(where: { $0.id == smartAlbum.localIdentifier }) {
                        let album = Album(result: fetchResult, id: smartAlbum.localIdentifier, name: smartAlbum.localizedTitle, isCameraRoll: true, needFetchAssets: needFetchAssets)
                        results.insert(album, at: 0)
                    }
                } else {
                    if !results.contains(where: { $0.id == smartAlbum.localIdentifier }) {
                        let album = Album(result: fetchResult, id: smartAlbum.localIdentifier, name: smartAlbum.localizedTitle, isCameraRoll: false, needFetchAssets: needFetchAssets)
                        results.append(album)
                    }
                }
            }
        }
        completion(results)
    }
}
