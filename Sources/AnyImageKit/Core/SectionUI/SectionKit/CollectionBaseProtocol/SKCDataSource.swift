//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit

class SKCDataSource: NSObject, UICollectionViewDataSource {
    
    private var _section: (_ indexPath: IndexPath) -> SKCDataSourceProtocol?
    private var _sections: () -> [SKCDataSourceProtocol]
    
    private func section(_ indexPath: IndexPath) -> SKCDataSourceProtocol? {
       return _section(indexPath)
    }
    
    private func sections() -> [SKCDataSourceProtocol] {
       return _sections()
    }
    
    init(section: @escaping (_ indexPath: IndexPath) -> SKCDataSourceProtocol?,
         sections: @escaping () -> [SKCDataSourceProtocol]) {
        self._section = section
        self._sections = sections
        super.init()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.section(IndexPath(row: 0, section: section))?.itemCount ?? 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let view = section(indexPath)?.item(at: indexPath.row) {
            return view
        } else {
            assertionFailure()
            return .init()
        }
    }
    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let view = section(indexPath)?.supplementary(kind: .init(rawValue: kind), at: indexPath.row) {
            return view
        } else {
            assertionFailure()
            return .init()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        section(indexPath)?.item(canMove: indexPath.row) ?? true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == destinationIndexPath.section {
            section(sourceIndexPath)?.move(from: sourceIndexPath, to: destinationIndexPath)
        } else {
            section(sourceIndexPath)?.move(from: sourceIndexPath, to: destinationIndexPath)
            section(destinationIndexPath)?.move(from: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    
    /// Returns a list of index titles to display in the index view (e.g. ["A", "B", "C" ... "Z", "#"])
    @available(iOS 14.0, *)
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        let indexTitles = sections().compactMap(\.indexTitle)
        return indexTitles.isEmpty ? nil : indexTitles
    }
    
    
    /// Returns the index path that corresponds to the given title / index. (e.g. "B",1)
    /// Return an index path with a single index to indicate an entire section, instead of a specific item.
    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        if let section = sections().filter({ $0.indexTitle == title }).dropFirst(index).first,
           let sectionIndex = section.sectionIndex {
            return .init(item: section.indexTitleRow, section: sectionIndex)
        } else {
            assertionFailure()
            return .init()
        }
    }
    
}
