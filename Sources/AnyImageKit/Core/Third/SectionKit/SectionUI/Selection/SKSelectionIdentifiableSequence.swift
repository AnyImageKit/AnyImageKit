//
//  File.swift
//
//
//  Created by linhey on 2022/9/9.
//

import Foundation
import Combine

public class SKSelectionIdentifiableSequence<Element: SKSelectionProtocol, ID: Hashable> {
    
    /// 是否保证选中在当前序列中是否唯一 | default: true
    public var isUnique: Bool
    
    public private(set) lazy var itemChangedPublisher = observer.eraseToAnyPublisher()
    public var selectedItemsPublisher: AnyPublisher<[Element], Never> {
        itemChangedPublisher.map(\.selectedItems).eraseToAnyPublisher()
    }

    private let observer = PassthroughSubject<SKSelectionIdentifiableSequence, Never>()
    
    public var values: [Element] { .init(store.values) }
    public private(set) var store: [ID: Element] = [:]
    
    private var cancelables: [ID: AnyCancellable] = [:]
    private let idPath: KeyPath<Element, ID>
    /// init
    /// - Parameters:
    ///   - items: 数据组
    ///   - id: 标识数据的ID
    ///   - isUnique: 是否保证选中在当前序列中是否唯一 | default: true
    public init(items: [Element] = [],
                id: KeyPath<Element, ID>,
                isUnique: Bool = true) {
        self.isUnique = isUnique
        self.idPath = id
        self.update(items, by: id)
    }
    
}

public extension SKSelectionIdentifiableSequence {
    
    func deselect(id: ID) {
        store[id]?.select(false)
    }
    
    func select(id: ID) {
        store[id]?.select(true)
    }
    
}

public extension SKSelectionIdentifiableSequence {
    
    var isSelectedAll: Bool {
        store.values.allSatisfy(\.isSelected)
    }
    
    var selectedItems: [Element] {
        store.values.filter(\.isSelected)
    }
    
    var selectedIDs: [ID] {
        store.filter(\.value.isSelected).map(\.key)
    }
    
}

public extension SKSelectionIdentifiableSequence {
    
    func reload(_ items: any Collection<Element> = []) {
        store.removeAll()
        cancelables.removeAll()
        update(items, by: idPath)
        observer.send(self)
    }
    
    func update(_ element: Element, by id: ID) {
        store[id] = element
        cancelables[id] = element.selectedPublisher
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] flag in
                guard let self = self else { return }
                self.observer.send(self)
                if flag {
                    if self.isUnique {
                        var ids = Set<ID>(self.selectedIDs)
                        ids.remove(id)
                        for id in ids {
                            self.deselect(id: id)
                        }
                    }
                }
            }
    }
    
    func update(_ element: Element, by keyPath: KeyPath<Element, ID>) {
        update(element, by: element[keyPath: keyPath])
    }
    
    func update(_ elements: any Collection<Element>, by keyPath: KeyPath<Element, ID>) {
        for element in elements {
            update(element, by: keyPath)
        }
    }
    
}

public extension SKSelectionIdentifiableSequence {
        
    func removeAll() {
        store.removeAll()
        cancelables.removeAll()
        observer.send(self)
    }

    func remove(id: any Collection<ID>) {
        for id in id {
            remove(id: id, observer: false)
        }
        observer.send(self)
    }

    func remove(id: ID) {
        remove(id: id, observer: true)
    }
    
    private func remove(id: ID, observer: Bool) {
        store[id] = nil
        cancelables[id] = nil
        if observer {
            self.observer.send(self)
        }
    }
    
    func contains(id: ID) -> Bool {
        return store[id] != nil
    }
    
    func selectAll() {
        store
            .values
            .filter { !$0.isSelected }
            .forEach { item in
                item.select(true)
            }
    }
    
    func deselectAll() {
        store
            .values
            .filter { $0.isSelected }
            .forEach { item in
                item.select(false)
            }
    }
    
}
