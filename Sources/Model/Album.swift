//
//  Album.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Foundation
import Photos

class Album: Equatable {
    
    let id: String
    let name: String
    let isCameraRoll: Bool
    private(set) var assets: [Asset] = []
    
    init(result: PHFetchResult<PHAsset>, id: String, name: String?, isCameraRoll: Bool, selectOptions: ImagePickerController.SelectOptions) {
        self.id = id
        self.name = name ?? ""
        self.isCameraRoll = isCameraRoll
        fetchAssets(result: result, selectOptions: selectOptions)
    }
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Album {
    
    var count: Int {
        return assets.count
    }
}

extension Album {
    
    private func fetchAssets(result: PHFetchResult<PHAsset>, selectOptions: ImagePickerController.SelectOptions) {
        var array: [Asset] = []
        let selectPhoto = selectOptions.contains(.photo)
        let selectPhotoGIF = selectOptions.contains(.photoGIF)
        let selectVideo = selectOptions.contains(.video)
        
        for phAsset in result.objects() {
            let asset = Asset(idx: array.count, asset: phAsset)
            switch asset.type {
            case .photo:
                if selectPhoto {
                    array.append(asset)
                }
            case .photoGif:
                if selectPhotoGIF {
                    array.append(asset)
                }
            case .video:
                if selectVideo {
                    array.append(asset)
                }
            }
        }
        assets = array
    }
}

extension Album: CustomStringConvertible {
    
    var description: String {
        return "Album<\(name)>"
    }
}
