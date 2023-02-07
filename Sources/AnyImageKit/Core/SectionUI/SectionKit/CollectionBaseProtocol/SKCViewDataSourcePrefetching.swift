//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit
import Combine

public class SKCViewDataSourcePrefetching: NSObject, UICollectionViewDataSourcePrefetching {

    public private(set) lazy var prefetchPublisher = prefetch.eraseToAnyPublisher()
    public private(set) lazy var cancelPrefetchingPublisher = cancelPrefetching.eraseToAnyPublisher()
    
    private var prefetch = PassthroughSubject<[IndexPath], Never>()
    private var cancelPrefetching = PassthroughSubject<[IndexPath], Never>()
    private var section: (_ index: Int) -> SKCViewDataSourcePrefetchingProtocol?

    init(section: @escaping (_ indexPath: Int) -> SKCViewDataSourcePrefetchingProtocol?) {
        self.section = section
        super.init()
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        prefetch(at: indexPaths)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        cancelPrefetch(at: indexPaths)
    }
    
}

private extension SKCViewDataSourcePrefetching {
    
    func prefetch(at indexPaths: [IndexPath]) {
        prefetch.send(indexPaths)
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
        cancelPrefetching.send(indexPaths)
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
