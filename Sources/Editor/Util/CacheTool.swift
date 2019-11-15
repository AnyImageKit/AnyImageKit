//
//  CacheTool.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/11/6.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

class CacheTool {
    
    private(set) var cacheList: [String] = []
    private var cache = NSCache<NSString, UIImage>()
    
    private let path: String
    private let queue = DispatchQueue(label: "AnyImageKit.CacheTool")
    
    init(name: String, limit: Int, cacheList: [String] = []) {
        self.cacheList = cacheList
        self.cache.countLimit = limit
        
        let lib = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
        path = "\(lib)/AnyImageKitCache/Editor/\(name)/"
        FileHelper.checkDirectory(path: path)
    }
    
    deinit {
        
    }
    
}

// MARK: - Public
extension CacheTool {
    
    func write(_ image: UIImage) {
        let key = createKey()
        cacheList.append(key)
        cache.setObject(image, forKey: key as NSString)
        writeToFile(image, name: key)
    }
    
    func read(delete: Bool = true) -> UIImage? {
        if !cacheList.isEmpty && delete {
            let key = cacheList.removeLast()
            cache.removeObject(forKey: key as NSString)
            loadDataFromFileIfNeeded()
        }
        if cacheList.isEmpty { return nil }
        let key = cacheList.last!
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        return readFromFile(key)
    }
    
    func hasCache() -> Bool {
        return !cacheList.isEmpty
    }
    
}

// MARK: - Private
extension CacheTool {

    private func removeDirectory(path: String) {
        let url = URL(fileURLWithPath: path)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            _print(error.localizedDescription)
        }
    }
    
    private func createKey() -> String {
        let timestamp = Int(Date().timeIntervalSince1970*100)
        let random = (arc4random() % 8999) + 1000
        return "\(timestamp)_\(random)"
    }
    
    private func writeToFile(_ image: UIImage, name: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let data = image.pngData() else { return }
            let url = URL(fileURLWithPath: self.path + name)
            do {
                try data.write(to: url)
            } catch {
                _print(error.localizedDescription)
            }
        }
    }
    
    private func readFromFile(_ name: String) -> UIImage? {
        let url = URL(fileURLWithPath: path + name)
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            _print(error.localizedDescription)
        }
        return nil
    }
    
    private func loadDataFromFileIfNeeded() {
        let idx = cacheList.count - cache.countLimit + 1
        guard idx >= 0 else { return }
        let key = cacheList[idx]
        if cache.object(forKey: key as NSString) != nil { return }
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let image = self.readFromFile(key) else { return }
            self.cache.setObject(image, forKey: key as NSString)
        }
    }
}
