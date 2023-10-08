//
//  ImageCacheable.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/12/1.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

public protocol ImageCacheable {
    func clearAll()
    func store(_ image: UIImage, forKey key: String)
    func retrieveImage(forKey key: String) -> UIImage?
}

public final class InMemoryImageCache: ImageCacheable {
    final class Key: NSObject {
        let key: String

        init(_ key: String) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? Key else {
                return false
            }

            return value.key == key
        }
    }
    var cache: NSCache = NSCache<Key, UIImage>()
    
    public func clearAll() {
        cache.removeAllObjects()
    }
    
    public func store(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: Key(key))
    }
    
    public func retrieveImage(forKey key: String) -> UIImage? {
        cache.object(forKey: Key(key))
    }
}
