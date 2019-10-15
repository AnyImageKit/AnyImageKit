//
//  PhotoManager.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import UIKit
import Photos

struct FetchRecord {
    
    var identifier: String
    var requestIDs: [PHImageRequestID]
}

final class PhotoManager {
    
    static let shared: PhotoManager = PhotoManager()
    
    var config = ImagePickerController.Config()
    
    var isMaxCount: Bool {
        return selectdAsset.count == config.maxCount
    }
    
    var isOriginalPhoto: Bool = false
    
    /// 已选中的资源
    private(set) var selectdAsset: [Asset] = []
    
    /// Running Fetch Requests
    private var fetchRecords = [FetchRecord]()
    
    /// 缓存
    private var cacheList = [(String, UIImage)]()
    
    private init() { }
    
    let workQueue = DispatchQueue(label: "com.anotheren.AnyImagePicker.PhotoManager")
}

extension PhotoManager {
    
    func clearAll() {
        selectdAsset.removeAll()
        cacheList.removeAll()
    }
}

// MARK: - Fetch Queue

extension PhotoManager {
    
    func enqueueFetch(for asset: PHAsset, requestID: PHImageRequestID) {
        workQueue.async {
            if let index = self.fetchRecords.firstIndex(where: { $0.identifier == asset.localIdentifier }) {
                self.fetchRecords[index].requestIDs.append(requestID)
            } else {
                self.fetchRecords.append(FetchRecord(identifier: asset.localIdentifier, requestIDs: [requestID]))
            }
        }
    }
    
    func dequeueFetch(for asset: PHAsset, requestID: PHImageRequestID?) {
        workQueue.async {
            guard let requestID = requestID else { return }
            if let index = self.fetchRecords.firstIndex(where: { $0.identifier == asset.localIdentifier }) {
                if let idx = self.fetchRecords[index].requestIDs.firstIndex(of: requestID) {
                    self.fetchRecords[index].requestIDs.remove(at: idx)
                }
            }
        }
    }
    
    func cancelFetch(for asset: PHAsset) {
        workQueue.async {
            if let index = self.fetchRecords.firstIndex(where: { $0.identifier == asset.localIdentifier }) {
                let fetchRecord = self.fetchRecords.remove(at: index)
                fetchRecord.requestIDs.forEach { PHImageManager.default().cancelImageRequest($0) }
            }
        }
    }
    
    func cancelAllFetch() {
        workQueue.async {
            for fetchRecord in self.fetchRecords {
                fetchRecord.requestIDs.forEach { PHImageManager.default().cancelImageRequest($0) }
            }
            self.fetchRecords.removeAll()
        }
    }
}

// MARK: - Cache

extension PhotoManager {
    
    private func removeCache(for identifier: String) {
        if let index = cacheList.firstIndex(where: { $0.0 == identifier }) {
            cacheList.remove(at: index)
        }
    }
    
    func readCache(for identifier: String) -> UIImage? {
        return cacheList.first(where: { $0.0 == identifier })?.1
    }
    
    func writeCache(image: UIImage, for identifier: String) {
        if cacheList.contains(where: { $0.0 == identifier }) {
            return
        }
        if cacheList.count > PhotoManager.shared.config.maxCount {
            cacheList.removeFirst()
        }
        cacheList.append((identifier, image))
    }
}

// MARK: - Select

extension PhotoManager {
    
    public func addSelectedAsset(_ asset: Asset) {
        selectdAsset.append(asset)
        asset.selectedNum = selectdAsset.count
        // 加载原图，缓存到内存
        workQueue.async { [weak self] in
            guard let self = self else { return }
            let options = PhotoFetchOptions(sizeMode: .preview)
            self.requestPhoto(for: asset.asset, options: options) { result in
                switch result {
                case .success(let response):
                    if !response.isDegraded {
                        let options2 = PhotoFetchOptions(sizeMode: .original)
                        self.requestPhoto(for: asset.asset, options: options2) { _ in }
                    }
                case .failure:
                    break
                }
            }
        }
    }
    
    public func removeSelectedAsset(_ asset: Asset) {
        guard let idx = PhotoManager.shared.selectdAsset.firstIndex(where: { $0 == asset }) else { return }
        for item in selectdAsset {
            if item.selectedNum > asset.selectedNum {
                item.selectedNum -= 1
            }
        }
        selectdAsset.remove(at: idx)
    }
    
    public func removeAllSelectedAsset() {
        selectdAsset.removeAll()
    }
}
