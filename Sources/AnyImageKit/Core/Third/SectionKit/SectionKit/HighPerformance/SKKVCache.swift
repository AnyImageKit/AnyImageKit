//
//  File.swift
//
//
//  Created by linhey on 2023/4/25.
//

#if canImport(ObjectiveC)
import ObjectiveC
import Foundation
// MARK: - Cache
public final class SKKVCache<Key: Hashable, Value> {
    
    public let wrapped = NSCache<WrappedKey, Entry>()
    public var dateProvider: (() -> Date)?
    public let keyTracker = KeyTracker()
    
    public var count: Int { keyTracker.keys.count }
    
    public var countLimit: Int {
        set { wrapped.countLimit = newValue }
        get { wrapped.countLimit }
    }
    
    public init(countLimit: Int? = nil,
                dateProvider: (() -> Date)? = nil) {
        wrapped.delegate = keyTracker
        self.dateProvider = dateProvider
        if let countLimit = countLimit {
            self.countLimit = countLimit
        }
    }
    
    public func insert(_ value: Value, forKey key: Key, lifeTime: TimeInterval? = nil) {
        let date: Date?
        if let lifeTime = lifeTime {
            date = dateProvider?().addingTimeInterval(lifeTime)
        } else {
            date = nil
        }
        self.insert(Entry(key: key, value: value, expirationDate: date))
    }
    
    public func remove(_ key: Key) {
        self[key] = nil
    }
    
    public func removeAll() {
        keyTracker.keys.removeAll()
        wrapped.removeAllObjects()
    }
}

// MARK: - Cache Subscript

public extension SKKVCache {
    
    subscript(_ key: WrappedKey) -> Entry? {
        get { entry(of: key) }
        set {
            remove(key)
            guard let newValue = newValue else { return }
            insert(newValue)
        }
    }
    
    subscript(_ key: Key) -> Value? {
        get { self[WrappedKey(key)]?.value }
        set { self[WrappedKey(key)] = newValue.map({ .init(key: key, value: $0) }) }
    }
    
}

// MARK: Cache.WrappedKey

public extension SKKVCache {
    
    final class WrappedKey: NSObject {
        public let key: Key
        public init(_ key: Key) { self.key = key }
        public override var hash: Int { key.hashValue }
        public override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
        
    }
}

// MARK: Cache.Entry

public extension SKKVCache {
    
    final class Entry {
        public let key: Key
        public let value: Value
        public let expirationDate: Date?
        
        public init(key: Key, value: Value, expirationDate: Date? = nil) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
    
}

// MARK: Cache.KeyTracker

public extension SKKVCache {
    
    final class KeyTracker: NSObject, NSCacheDelegate {
        public var keys = Set<Key>()
        
        public func cache(_: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            guard let entry = obj as? Entry else {
                return
            }
            keys.remove(entry.key)
        }
    }
    
}

// MARK: - Cache.Entry + Codable

extension SKKVCache.Entry: Codable where Key: Codable, Value: Codable {}

private extension SKKVCache {
    
    func entry(of key: WrappedKey) -> Entry? {
        guard let entry = wrapped.object(forKey: key) else {
            return nil
        }
        
        if let expirationDate = entry.expirationDate,
           let now = dateProvider?(),
           now >= expirationDate {
            remove(key)
            return nil
        }
        
        return entry
    }
    
    func remove(_ key: WrappedKey) {
        keyTracker.keys.remove(key.key)
        wrapped.removeObject(forKey: key)
    }
    
    func insert(_ entry: Entry) {
        keyTracker.keys.insert(entry.key)
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
    }
}

// MARK: - Cache + Codable

extension SKKVCache: Codable where Key: Codable, Value: Codable {
    
    public convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap({ self.entry(of: .init($0)) }))
    }
    
}
#endif
