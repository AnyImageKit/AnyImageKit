//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

#if canImport(UIKit)
import UIKit
import Combine

public struct SKCDataSourcePrefetching: SKCDataSourcePrefetchingForwardProtocol {

    struct PrefetchPublishers {
        public private(set) lazy var prefetch = prefetchSubject.removeDuplicates().eraseToAnyPublisher()
        public private(set) lazy var cancelPrefetching = cancelPrefetchingSubject.removeDuplicates().eraseToAnyPublisher()
        let prefetchSubject = PassthroughSubject<[IndexPath], Never>()
        let cancelPrefetchingSubject = PassthroughSubject<[IndexPath], Never>()
    }
    
    public var isEnable: Bool = false
    let dataSource: SKCManagerPublishers
    let publishers: PrefetchPublishers = .init()

    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) -> SKHandleResult<Void> {
        .handleable(prefetch(at: indexPaths))
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) -> SKHandleResult<Void> {
        .handleable(cancelPrefetch(at: indexPaths))
    }

    private func section(_ index: Int) -> SKCViewDataSourcePrefetchingProtocol? {
        return dataSource.safe(section: index)
    }
    
}

private extension SKCDataSourcePrefetching {
    
    func prefetch(at indexPaths: [IndexPath]) {
        guard isEnable else { return }
        publishers.prefetchSubject.send(indexPaths)
        var store = [Int: [Int]]()
        for indexPath in indexPaths {
            if store[indexPath.section] == nil {
                store[indexPath.section] = [indexPath.row]
            } else {
                store[indexPath.section]?.append(indexPath.row)
            }
        }
        for (key, value) in store {
            section(key)?.prefetch(at: value)
        }
    }
    
    func cancelPrefetch(at indexPaths: [IndexPath]) {
        guard isEnable else { return }
        publishers.cancelPrefetchingSubject.send(indexPaths)
        var store = [Int: [Int]]()
        for indexPath in indexPaths {
            if store[indexPath.section] == nil {
                store[indexPath.section] = [indexPath.row]
            } else {
                store[indexPath.section]?.append(indexPath.row)
            }
        }
        for (key, value) in store {
            section(key)?.cancelPrefetching(at: value)
        }
    }
    
}

#endif
