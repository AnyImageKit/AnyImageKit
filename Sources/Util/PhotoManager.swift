//
//  PhotoManager.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos

final public class PhotoManager {
    
    
}

extension PhotoManager {
    
    func fetchCameraRollAlbum(allowPickingVideo: Bool, allowPickingImage: Bool, needFetchAssets: Bool, completion: () -> Void) {
        let options = PHFetchOptions()
        if !allowPickingVideo {
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        if !allowPickingImage {
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        options.sortDescriptors = [sortDescriptor]
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: options)
        smartAlbums.enumerateObjects { (assetCollection, index, isAtEnd) in
            if assetCollection.estimatedAssetCount > 0 {
                
            }
        }
    }
    
//    - (void)getCameraRollAlbum:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage needFetchAssets:(BOOL)needFetchAssets completion:(void (^)(TZAlbumModel *model))completion {
//        __block TZAlbumModel *model;
//        PHFetchOptions *option = [[PHFetchOptions alloc] init];
//        if (!allowPickingVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
//        if (!allowPickingImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
//                                                    PHAssetMediaTypeVideo];
//        // option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:self.sortAscendingByModificationDate]];
//        if (!self.sortAscendingByModificationDate) {
//            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
//        }
//        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
//        for (PHAssetCollection *collection in smartAlbums) {
//            // 有可能是PHCollectionList类的的对象，过滤掉
//            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
//            // 过滤空相册
//            if (collection.estimatedAssetCount <= 0) continue;
//            if ([self isCameraRollAlbum:collection]) {
//                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
//                model = [self modelWithResult:fetchResult name:collection.localizedTitle isCameraRoll:YES needFetchAssets:needFetchAssets];
//                if (completion) completion(model);
//                break;
//            }
//        }
//    }
    
}
