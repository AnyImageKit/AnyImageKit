//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

#if canImport(UIKit)
import UIKit

public struct SKCDataSource: SKCDataSourceForwardableProtocol {
    
    let dataSource: SKCManagerPublishers
    
}

public extension SKCDataSource {
    
    func section(_ indexPath: IndexPath) -> SKCDataSourceProtocol? {
        return dataSource.safe(section: indexPath.section)
    }
    
    func sections() -> any Collection<SKCDataSourceProtocol> {
        return dataSource.collection()
    }
    
}

public extension SKCDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> SKHandleResult<Int> {
        return .handle(sections().count)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> SKHandleResult<Int> {
        return .handle(self.section(IndexPath(row: 0, section: section))?.itemCount ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> SKHandleResult<UICollectionViewCell> {
        return .handleable(section(indexPath)?.item(at: indexPath.row))
    }
    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> SKHandleResult<UICollectionReusableView> {
        return .handleable(section(indexPath)?.supplementary(kind: .init(rawValue: kind), at: indexPath.row))
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> SKHandleResult<Bool> {
        .handleable(section(indexPath)?.item(canMove: indexPath.row))
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> SKHandleResult<Void> {
        if sourceIndexPath.section == destinationIndexPath.section {
            section(sourceIndexPath)?.move(from: sourceIndexPath, to: destinationIndexPath)
        } else {
            section(sourceIndexPath)?.move(from: sourceIndexPath, to: destinationIndexPath)
            section(destinationIndexPath)?.move(from: sourceIndexPath, to: destinationIndexPath)
        }
        return .handle
    }
    
    /// Returns a list of index titles to display in the index view (e.g. ["A", "B", "C" ... "Z", "#"])
    @available(iOS 14.0, *)
    func indexTitles(for collectionView: UICollectionView) -> SKHandleResult<[String]?> {
        let indexTitles = sections().compactMap(\.indexTitle)
        return .handle(indexTitles.isEmpty ? nil : indexTitles)
    }
    
    /// Returns the index path that corresponds to the given title / index. (e.g. "B",1)
    /// Return an index path with a single index to indicate an entire section, instead of a specific item.
    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> SKHandleResult<IndexPath> {
        guard let section = sections()
            .filter({ $0.indexTitle != nil })
            .enumerated()
            .first(where: { $0.offset == index })?
            .element,
              let sectionIndex = section.sectionIndex else {
            return .next
        }
        return .handle(.init(item: section.indexTitleRow, section: sectionIndex))
    }
    
}
#endif
