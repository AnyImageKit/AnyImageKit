//
//  File.swift
//
//
//  Created by linhey on 2024/3/13.
//

import UIKit

public protocol SKCDataSourceForwardableProtocol {
    func numberOfSections(in collectionView: UICollectionView) -> SKHandleResult<Int>
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> SKHandleResult<Int>
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> SKHandleResult<UICollectionViewCell>
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> SKHandleResult<UICollectionReusableView>
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> SKHandleResult<Bool>
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> SKHandleResult<Void>
    @available(iOS 14.0, *)
    func indexTitles(for collectionView: UICollectionView) -> SKHandleResult<[String]?>
    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> SKHandleResult<IndexPath>
}

public extension SKCDataSourceForwardableProtocol {
    
    func numberOfSections(in collectionView: UICollectionView) -> SKHandleResult<Int> { .next }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> SKHandleResult<Int> { .next }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> SKHandleResult<UICollectionViewCell> { .next }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> SKHandleResult<UICollectionReusableView> { .next }
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> SKHandleResult<Bool> { .next }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> SKHandleResult<Void> { .next }
    @available(iOS 14.0, *)
    func indexTitles(for collectionView: UICollectionView) -> SKHandleResult<[String]?> { .next }
    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> SKHandleResult<IndexPath> { .next }
    
}

public protocol SKCDataSourceObserverProtocol {
    func numberOfSections(in collectionView: UICollectionView, value: Int)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int, value: Int)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, value: UICollectionViewCell)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath, value: UICollectionReusableView)
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath, value: Bool)
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath, value: Void)
    @available(iOS 14.0, *)
    func indexTitles(for collectionView: UICollectionView, value: [String]?)
    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int, value: IndexPath)
}

public extension SKCDataSourceObserverProtocol {
    
    func numberOfSections(in collectionView: UICollectionView, value: Int) {}
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int, value: Int) {}
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, value: UICollectionViewCell) {}
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath, value: UICollectionReusableView) {}
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath, value: Bool) {}
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath, value: Void) {}
    @available(iOS 14.0, *)
    func indexTitles(for collectionView: UICollectionView, value: [String]?) {}
    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int, value: IndexPath) {}
    
}

public class SKCDataSourceForward: NSObject, UICollectionViewDataSource {
    
    class SKDebugReusableCell: UICollectionViewCell, SKLoadViewProtocol {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .systemRed
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            backgroundColor = .systemRed
        }
        
    }
    
    var forwardItems: [SKCDataSourceForwardableProtocol]
    var observerItems: [SKCDataSourceObserverProtocol]
    
    init(_ items: [SKCDataSourceForwardableProtocol] = [],
         observerItems: [SKCDataSourceObserverProtocol] = []) {
        self.forwardItems = items
        self.observerItems = observerItems
    }
    
    public func add(_ item: SKCDataSourceObserverProtocol) {
        observerItems.append(item)
    }
    
    public func add(_ item: SKCDataSourceForwardableProtocol) {
        forwardItems.append(item)
    }
    
    func find<T>(`default`: @autoclosure () -> T, _ task: (_ item: SKCDataSourceForwardableProtocol) -> SKHandleResult<T>) -> T {
        for item in forwardItems.reversed() {
            let result = task(item)
            switch result {
            case .handle(let value):
                return value
            case .next:
                break
            }
        }
        return `default`()
    }
    
    func find(_ task: (_ item: SKCDataSourceForwardableProtocol) -> SKHandleResult<Void>) -> Void {
        return find(default: (), task)
    }
    
    func observe(_ task: (_ item: SKCDataSourceObserverProtocol) -> Void) {
        observerItems.forEach(task)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        let value = find(default: 0) { item in
            item.numberOfSections(in: collectionView)
        }
        observe { item in
            item.numberOfSections(in: collectionView, value: value)
        }
        return value
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let value = find(default: 0) { item in
            item.collectionView(collectionView, numberOfItemsInSection: section)
        }
        observe { item in
            item.collectionView(collectionView, numberOfItemsInSection: section, value: value)
        }
        return value
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let value = find(default: {
            collectionView.register(SKDebugReusableCell.self, forCellWithReuseIdentifier: SKDebugReusableCell.identifier)
            return collectionView.dequeueReusableCell(withReuseIdentifier: SKDebugReusableCell.identifier, for: indexPath)
        }()) { item in
            item.collectionView(collectionView, cellForItemAt: indexPath)
        }
        observe { item in
            item.collectionView(collectionView, cellForItemAt: indexPath, value: value)
        }
        return value
    }
    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let value = find(default: {
            collectionView.register(SKDebugReusableCell.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: SKDebugReusableCell.identifier)
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SKDebugReusableCell.identifier, for: indexPath)
        }()) { item in
            item.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
        observe { item in
            item.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath, value: value)
        }
        return value
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        let value = find(default: false) { item in
            item.collectionView(collectionView, canMoveItemAt: indexPath)
        }
        observe { item in
            item.collectionView(collectionView, canMoveItemAt: indexPath, value: value)
        }
        return value
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let value: Void = find { item in
            item.collectionView(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)
        }
        observe { item in
            item.collectionView(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath, value: value)
        }
        return value
    }
    
    
    /// Returns a list of index titles to display in the index view (e.g. ["A", "B", "C" ... "Z", "#"])
    @available(iOS 14.0, *)
    public func indexTitles(for collectionView: UICollectionView) -> [String]? {
        let value = find(default: nil) { item in
            item.indexTitles(for: collectionView)
        }
        observe { item in
            item.indexTitles(for: collectionView, value: value)
        }
        return value
    }
    
    
    /// Returns the index path that corresponds to the given title / index. (e.g. "B",1)
    /// Return an index path with a single index to indicate an entire section, instead of a specific item.
    @available(iOS 14.0, *)
    public func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        let value = find(default: .init()) { item in
            item.collectionView(collectionView, indexPathForIndexTitle: title, at: index)
        }
        observe { item in
            item.collectionView(collectionView, indexPathForIndexTitle: title, at: index, value: value)
        }
        return value
    }
    
}
