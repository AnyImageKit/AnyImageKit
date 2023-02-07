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
    public private(set) lazy var itemChangedPublisher = itemChangedSubject.eraseToAnyPublisher()
    
    private let itemChangedSubject = PassthroughSubject<[ID: Element], Never>()
    public private(set) var store: [ID: Element] = [:]
    private var selectedStore: [ID: AnyCancellable] = [:]
    private var isObserving: Bool = true
    
    public init(items: [Element] = [],
                id: KeyPath<Element, ID>,
                isUnique: Bool = true) {
        self.isUnique = isUnique
        items.forEach { element in
            update(element, by: id)
        }
    }
    
}

public extension SKSelectionIdentifiableSequence {
    
    func update(_ element: Element, by id: ID) {
        store[id] = element
        observe(element, by: id)
    }
    
    func update(_ element: Element, by keyPath: KeyPath<Element, ID>) {
        update(element, by: element[keyPath: keyPath])
    }
    
    func update(_ elements: [Element], by keyPath: KeyPath<Element, ID>) {
        for element in elements {
            update(element, by: keyPath)
        }
    }

    func removeAll() {
        store.removeAll()
        selectedStore.removeAll()
    }
    
    func remove(id: ID) {
        store[id] = nil
        selectedStore[id] = nil
    }
    
    func contains(id: ID) -> Bool {
        return store[id] != nil
    }
    
    func deselect(id: ID) {
        isObserving = false
        store[id]?.isSelected = false
        isObserving = true
    }
    
    func select(id: ID) {
        isObserving = false
        maintainUniqueIfNeed(exclude: id)
        store[id]?.isSelected = true
        isObserving = true
    }
    
}

private extension SKSelectionIdentifiableSequence {
    
    func observe(_ element: Element?, by id: ID) {
        selectedStore[id] = element?
            .selectedPublisher
            .dropFirst()
            .sink(receiveValue: { [weak self] flag in
                guard let self = self, self.isObserving else { return }
                if flag {
                    self.select(id: id)
                } else {
                    self.deselect(id: id)
                }
                self.itemChangedSubject.send(self.store)
            })
    }
    
    func maintainUniqueIfNeed(exclude id: ID) {
        guard isUnique else {
            return
        }

        store
            .filter({ $0.key != id })
            .map(\.value)
            .filter(\.isSelected)
            .forEach { element in
                element.isSelected = false
            }
    }
    
}
