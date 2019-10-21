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
    
    public func insertAsset(_ asset: Asset, at: Int) {
        assets.insert(asset, at: at)
        reloadIndex()
    }
    
    public func addAsset(_ asset: Asset, atLast: Bool) {
        if atLast {
            assets.append(asset)
        } else {
            assets.insert(asset, at: assets.count-1)
        }
    }
}

extension Album {
    
    private func fetchAssets(result: PHFetchResult<PHAsset>, selectOptions: ImagePickerController.SelectOptions) {
        var array: [Asset] = []
        let selectPhoto = selectOptions.contains(.photo)
        let selectPhotoGIF = selectOptions.contains(.photoGIF)
        let selectVideo = selectOptions.contains(.video)
        let selectPhotoLive = selectOptions.contains(.photoLive)
        
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
            case .photoLive:
                if selectPhotoLive {
                    array.append(asset)
                }
            }
        }
        assets = array
    }
    
    private func reloadIndex() {
        var idx = 0
        let array: [Asset]
        switch PhotoManager.shared.config.orderByDate {
        case .asc:
            array = Array(assets[0..<assets.count-1])
        case .desc:
            array = Array(assets[1..<assets.count])
        }
        for asset in array {
            asset.idx = idx
            idx += 1
        }
    }
}

extension Album {
    
    var count: Int {
        return assets.count
    }
}

extension Album: CustomStringConvertible {
    
    var description: String {
        return "Album<\(name)>"
    }
}
