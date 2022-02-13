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
    
    var useOriginalImage: Bool = false
    
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
    
    
}

// MARK: - Private function
extension PickerManager {
    
    
}
