//
//  File.swift
//  
//
//  Created by linhey on 2024/3/15.
//

import UIKit

public class SKCDataSourcePrefetchingForward: NSObject, UICollectionViewDataSourcePrefetching {
  
    var forwardItems: [SKCDataSourcePrefetchingForwardProtocol]
    var observerItems: [SKCDataSourcePrefetchingObserverProtocol]
    
    init(_ items: [SKCDataSourcePrefetchingForwardProtocol] = [],
         observerItems: [SKCDataSourcePrefetchingObserverProtocol] = []) {
        self.forwardItems = items
        self.observerItems = observerItems
    }
    
    public func add(_ item: SKCDataSourcePrefetchingObserverProtocol) {
        observerItems.append(item)
    }
    
    public func add(_ item: SKCDataSourcePrefetchingForwardProtocol) {
        forwardItems.append(item)
    }
    
    func find<T>(`default`: T, _ task: (_ item: SKCDataSourcePrefetchingForwardProtocol) -> SKHandleResult<T>) -> T {
        for item in forwardItems.reversed() {
            let result = task(item)
            switch result {
            case .handle(let value):
                return value
            case .next:
                break
            }
        }
        return `default`
    }
    
    func find(_ task: (_ item: SKCDataSourcePrefetchingForwardProtocol) -> SKHandleResult<Void>) -> Void {
        return find(default: (), task)
    }
    
    func observe(_ task: (_ item: SKCDataSourcePrefetchingObserverProtocol) -> Void) {
        observerItems.forEach(task)
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let value: Void = find { $0.collectionView(collectionView, prefetchItemsAt: indexPaths) }
        observe { item in
            item.collectionView(collectionView, prefetchItemsAt: indexPaths, value: value)
        }
        return value
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let value: Void = find { $0.collectionView(collectionView, cancelPrefetchingForItemsAt: indexPaths) }
        observe { item in
            item.collectionView(collectionView, cancelPrefetchingForItemsAt: indexPaths, value: value)
        }
        return value
    }
    
    
}
