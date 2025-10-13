//
//  File.swift
//  
//
//  Created by linhey on 2023/4/25.
//

#if canImport(ObjectiveC) && canImport(UIKit)
import ObjectiveC
import Foundation
import CoreFoundation

public class SKHighPerformanceStore<ID: Hashable> {
    
    public struct CacheKey: Hashable {
        
        public let id: ID
        public let size: CGSize
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(size.width)
            hasher.combine(size.height)
        }
        
    }
    
    public var sizeCached: SKKVCache<CacheKey, CGSize>
    
    public init(sizeCached: SKKVCache<CacheKey, CGSize> = .init()) {
        self.sizeCached = sizeCached
    }
    
}

public extension SKHighPerformanceStore {
    
    @discardableResult
    func cache(by id: ID,
               limit: CGSize,
               calculate: (_ limit: CGSize) -> CGSize) -> CGSize {
        let key = CacheKey(id: id, size: limit)
        if let value = sizeCached[key] {
            SKPrint.highPerformance("hit cache: id:\(key.id) size:\(value) limit:\(key.size)")
            return value
        }
        let calculate = calculate(limit)
        sizeCached[key] = calculate
        SKPrint.highPerformance("cache: id:\(key.id) size:\(calculate) limit:\(key.size)")
        return calculate
    }
    
    @discardableResult
    func cache<T: AnyObject>(by object: T,
                             limit: CGSize,
                             calculate: (_ limit: CGSize) -> CGSize) -> CGSize where ID == ObjectIdentifier {
        return cache(by: ObjectIdentifier(object), limit: limit, calculate: calculate)
    }
    
    func remove<T: AnyObject>(by object: T, limit: CGSize) where ID == ObjectIdentifier {
        remove(by: ObjectIdentifier(object), limit: limit)
    }
    
    func remove(by id: ID, limit: CGSize) {
        sizeCached[.init(id: id, size: limit)] = nil
    }
    
    func removeAll() {
        sizeCached.removeAll()
    }
    
}

#endif
