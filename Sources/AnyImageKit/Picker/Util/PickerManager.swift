//
//  PickerManager.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos

struct FetchRecord {
    
    let identifier: String
    var requestIDs: [PHImageRequestID]
}

final class PickerManager {
    
    var options: PickerOptionsInfo = .init()
    
    var isUpToLimit: Bool {
        return selectedAssets.count == options.selectLimit
    }
    
    var useOriginalImage: Bool = false
    
    /// 已选中的资源
    private(set) var selectedAssets: [Asset] = []
    /// 获取失败的资源
    private var failedAssets: [Asset] = []
    /// 管理 failedAssets 队列的锁
    private let lock: NSLock = .init()
    
    /// Running Fetch Requests
    private var fetchRecords = [FetchRecord]()
    
    /// 缓存
    let cache = ImageCacheTool(module: .picker(.default), memoryCountLimit: 10, useDiskCache: false)
    
    init() { }
    
    let workQueue = DispatchQueue(label: "org.AnyImageKit.DispatchQueue.PickerManager")
    let resizeSemaphore = DispatchSemaphore(value: 3)
}

extension PickerManager {
    
    func clearAll() {
        useOriginalImage = false
        selectedAssets.removeAll()
        failedAssets.removeAll()
        cache.clearAll()
        cancelAllFetch()
    }
}

// MARK: - Fetch Queue

extension PickerManager {
    
    func enqueueFetch(for identifier: String, requestID: PHImageRequestID) {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            if let index = self.fetchRecords.firstIndex(where: { $0.identifier == identifier }) {
                self.fetchRecords[index].requestIDs.append(requestID)
            } else {
                self.fetchRecords.append(FetchRecord(identifier: identifier, requestIDs: [requestID]))
            }
        }
    }
    
    func dequeueFetch(for identifier: String, requestID: PHImageRequestID?) {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            guard let requestID = requestID else { return }
            if let index = self.fetchRecords.firstIndex(where: { $0.identifier == identifier }) {
                if let idx = self.fetchRecords[index].requestIDs.firstIndex(of: requestID) {
                    self.fetchRecords[index].requestIDs.remove(at: idx)
                }
                if self.fetchRecords[index].requestIDs.isEmpty {
                    self.fetchRecords.remove(at: index)
                }
            }
        }
    }
    
    func cancelFetch(for identifier: String) {
        if let index = self.fetchRecords.firstIndex(where: { $0.identifier == identifier }) {
            let fetchRecord = self.fetchRecords.remove(at: index)
            fetchRecord.requestIDs.forEach { PHImageManager.default().cancelImageRequest($0) }
        }
    }
    
    func cancelAllFetch() {
        for fetchRecord in self.fetchRecords {
            fetchRecord.requestIDs.forEach { PHImageManager.default().cancelImageRequest($0) }
        }
        self.fetchRecords.removeAll()
    }
}

// MARK: - Select

extension PickerManager {
    
    @discardableResult
    func addSelectedAsset(_ asset: Asset) -> (success: Bool, message: String) {
        if selectedAssets.contains(asset) { return (false, "") }
        
        if asset.state == .unchecked {
            asset.check(disable: options.disableRules, assetList: selectedAssets)
        }
        if case .disable(let rule) = asset.state {
            let message = rule.alertMessage(for: asset, assetList: selectedAssets)
            return (false, message)
        }
        
        if !asset.isSelected && isUpToLimit {
            let message: String
            if options.selectOptions.isPhoto && options.selectOptions.isVideo {
                message = String(format: options.theme[string: .pickerSelectMaximumOfPhotosOrVideos], options.selectLimit)
            } else if options.selectOptions.isPhoto {
                message = String(format: options.theme[string: .pickerSelectMaximumOfPhotos], options.selectLimit)
            } else {
                message = String(format: options.theme[string: .pickerSelectMaximumOfVideos], options.selectLimit)
            }
            return (false, message)
        }
        
        selectedAssets.append(asset)
        asset.state = .selected
        asset.selectedNum = selectedAssets.count
        syncAsset(asset)
        return (true, "")
    }
    
    @discardableResult
    func removeSelectedAsset(_ asset: Asset) -> Bool {
        guard let idx = selectedAssets.firstIndex(where: { $0 == asset }) else { return false }
        for item in selectedAssets {
            if item.selectedNum > asset.selectedNum {
                item.selectedNum -= 1
            }
        }
        selectedAssets.remove(at: idx)
        asset.state = .normal
        asset._images[.initial] = nil
        return true
    }
    
    func removeAllSelectedAsset() {
        selectedAssets.removeAll()
    }
    
    func syncAsset(_ asset: Asset) {
        switch asset.mediaType {
        case .photo, .photoGIF, .photoLive:
            // 勾选图片就开始加载
            if let image = cache.retrieveImage(forKey: asset.identifier) {
                asset._images[.initial] = image
                self.didSyncAsset()
            } else {
                workQueue.async { [weak self] in
                    guard let self = self else { return }
                    let options = _PhotoFetchOptions(sizeMode: .preview(self.options.largePhotoMaxWidth))
                    self.requestPhoto(for: asset.phAsset, options: options) { result in
                        switch result {
                        case .success(let response):
                            if !response.isDegraded {
                                asset._images[.initial] = response.image
                                self.didSyncAsset()
                            }
                        case .failure(let error):
                            self.lock.lock()
                            self.failedAssets.append(asset)
                            self.lock.unlock()
                            _print(error)
                            let message = self.options.theme[string: .pickerFetchFailedPleaseRetry]
                            NotificationCenter.default.post(name: .didSyncAsset, object: message)
                        }
                    }
                }
            }
        case .video:
            workQueue.async { [weak self] in
                guard let self = self else { return }
                let options = _PhotoFetchOptions(sizeMode: .preview(500), needCache: true)
                self.requestPhoto(for: asset.phAsset, options: options, completion: { result in
                    switch result {
                    case .success(let response):
                        asset._images[.initial] = response.image
                    case .failure:
                        break
                    }
                })
                // 同步请求图片
                self.requestVideo(for: asset.phAsset) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(_):
                        asset.videoDidDownload = true
                        self.didSyncAsset()
                    case .failure(let error):
                        self.lock.lock()
                        self.failedAssets.append(asset)
                        self.lock.unlock()
                        _print(error)
                        let message = self.options.theme[string: .pickerFetchFailedPleaseRetry]
                        NotificationCenter.default.post(name: .didSyncAsset, object: message)
                    }
                }
            }
        }
    }
    
    func resynchronizeAsset() {
        lock.lock()
        let assets = failedAssets
        failedAssets.removeAll()
        lock.unlock()
        assets.forEach { syncAsset($0) }
    }
}

// MARK: - Private function
extension PickerManager {
    
    private func didSyncAsset() {
        let isReady = selectedAssets.filter{ !$0.isReady }.isEmpty
        if isReady {
            NotificationCenter.default.post(name: .didSyncAsset, object: nil)
        }
    }
}
