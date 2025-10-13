//
//  File.swift
//  
//
//  Created by linhey on 2024/3/15.
//

import UIKit

public protocol SKCDataSourcePrefetchingForwardProtocol {
    // indexPaths are ordered ascending by geometric distance from the collection view
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) -> SKHandleResult<Void>
    // indexPaths that previously were considered as candidates for pre-fetching, but were not actually used; may be a subset of the previous call to -collectionView:prefetchItemsAtIndexPaths:
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) -> SKHandleResult<Void>
}

extension SKCDataSourcePrefetchingForwardProtocol {
    // indexPaths are ordered ascending by geometric distance from the collection view
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) -> SKHandleResult<Void> { .next }
    // indexPaths that previously were considered as candidates for pre-fetching, but were not actually used; may be a subset of the previous call to -collectionView:prefetchItemsAtIndexPaths:
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) -> SKHandleResult<Void> { .next }
}
