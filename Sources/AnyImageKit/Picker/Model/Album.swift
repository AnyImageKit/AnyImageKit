//
//  Album.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import Photos

final class Album: IdentifiableResource {

    enum DisplaySort {
        case recentlyAdded
        case capturedDate
    }

    let fetchResult: PHFetchResult<PHAsset>
    let identifier: String
    let title: String
    let isCameraRoll: Bool

    private let selectOptions: PickerSelectOption
    private let sort: Sort
    let filter: PickerMediaTypeFilter
    let displaySort: DisplaySort
    private var baseIndexes: [Int]?
    private let cachedAssets: NSCache<NSString, Asset> = {
        let cache = NSCache<NSString, Asset>()
        cache.countLimit = 500
        return cache
    }()
    private var retainedAssets: [String: Asset] = [:]
    private var cameraAsset: Asset?

    init(fetchResult: PHFetchResult<PHAsset>,
         identifier: String,
         title: String?,
         isCameraRoll: Bool,
         selectOptions: PickerSelectOption,
         sort: Sort,
         filter: PickerMediaTypeFilter = .all,
         displaySort: DisplaySort = .recentlyAdded) {
        self.fetchResult = fetchResult
        self.identifier = identifier
        self.title = title ?? ""
        self.isCameraRoll = isCameraRoll
        self.selectOptions = selectOptions
        self.sort = sort
        self.filter = filter
        self.displaySort = displaySort

        // Plain photo selection accepts every image returned by PhotoKit. More
        // specific GIF/Live Photo combinations need an exact source index map.
        if !selectOptions.contains(.photo) && selectOptions.isPhoto {
            baseIndexes = (0..<fetchResult.count).compactMap { index in
                let mediaType = MediaType(asset: fetchResult.object(at: index), selectOptions: selectOptions)
                switch mediaType {
                case .photoGIF:
                    return selectOptions.contains(.photoGIF) ? index : nil
                case .photoLive:
                    return selectOptions.contains(.photoLive) ? index : nil
                case .video:
                    return selectOptions.contains(.video) ? index : nil
                case .photo:
                    return nil
                }
            }
        }
    }

    var count: Int {
        baseIndexes?.count ?? fetchResult.count
    }

    var itemCount: Int {
        count + (cameraAsset == nil ? 0 : 1)
    }

    var hasCamera: Bool {
        cameraAsset != nil
    }

    func asset(at displayIndex: Int) -> Asset? {
        if let cameraAsset, displayIndex == cameraDisplayIndex {
            return cameraAsset
        }
        guard let sourceIndex = sourceIndex(for: displayIndex) else { return nil }
        let phAsset = fetchResult.object(at: sourceIndex)
        if let asset = retainedAssets[phAsset.localIdentifier] {
            return asset
        }
        if let asset = cachedAssets.object(forKey: phAsset.localIdentifier as NSString) {
            return asset
        }
        let asset = Asset(idx: sourceIndex, asset: phAsset, selectOptions: selectOptions)
        cachedAssets.setObject(asset, forKey: asset.identifier as NSString)
        return asset
    }

    func mediaAsset(at index: Int) -> Asset? {
        guard index >= 0 && index < count else { return nil }
        return asset(at: index + cameraOffset)
    }

    func displayIndex(for asset: Asset) -> Int? {
        displayIndex(forIdentifier: asset.identifier)
    }

    func displayIndex(forIdentifier identifier: String) -> Int? {
        if cameraAsset?.identifier == identifier { return cameraDisplayIndex }
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let phAsset = result.firstObject else { return nil }
        let sourceIndex = fetchResult.index(of: phAsset)
        guard sourceIndex != NSNotFound else { return nil }

        let logicalIndex: Int?
        if let baseIndexes {
            guard let index = baseIndexes.firstIndex(of: sourceIndex) else { return nil }
            logicalIndex = sort == .asc ? index : count - index - 1
        } else {
            logicalIndex = sort == .asc ? sourceIndex : count - sourceIndex - 1
        }
        guard let logicalIndex else { return nil }
        return logicalIndex + cameraOffset
    }

    func contains(identifier: String) -> Bool {
        displayIndex(forIdentifier: identifier) != nil
    }

    func cache(_ asset: Asset) {
        retainedAssets[asset.identifier] = asset
        cachedAssets.setObject(asset, forKey: asset.identifier as NSString)
    }

    func addCameraAsset(_ asset: Asset) {
        cameraAsset = asset
    }

    func firstMediaAsset() -> Asset? {
        guard count > 0 else { return nil }
        return asset(at: cameraOffset)
    }

    func lastMediaAsset() -> Asset? {
        guard count > 0 else { return nil }
        return asset(at: cameraOffset + count - 1)
    }

    private var cameraDisplayIndex: Int? {
        guard cameraAsset != nil else { return nil }
        return sort == .asc ? count : 0
    }

    private var cameraOffset: Int {
        cameraAsset != nil && sort == .desc ? 1 : 0
    }

    private func sourceIndex(for displayIndex: Int) -> Int? {
        let logicalIndex = displayIndex - cameraOffset
        guard logicalIndex >= 0 && logicalIndex < count else { return nil }
        if let baseIndexes {
            return sort == .asc ? baseIndexes[logicalIndex] : baseIndexes[count - logicalIndex - 1]
        }
        return sort == .asc ? logicalIndex : count - logicalIndex - 1
    }
}

extension Album: CustomStringConvertible {
    var description: String {
        "Album<\(title)>"
    }
}
