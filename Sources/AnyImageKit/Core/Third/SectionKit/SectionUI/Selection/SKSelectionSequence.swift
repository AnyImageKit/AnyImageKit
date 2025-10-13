//
//  File.swift
//
//
//  Created by linhey on 2022/9/9.
//

import Foundation
import Combine

public extension SKCSingleTypeSection where Model: SKSelectionProtocol {
    
    func selectionSequence(isUnique: Bool = true) -> SKSelectionSequence<Model> {
        let sequence = SKSelectionSequence<Model>(isUnique: isUnique)
        sequence.subscribe = self.publishers.modelsPulisher.sink { [weak sequence] items in
            guard let sequence = sequence else { return }
            sequence.reload(items)
        }
        return sequence
    }
    
}

public final class SKSelectionSequence<Element: SKSelectionProtocol> {
    
    public struct ChangedContent {
        public let offset: Int
        public let element: Element
    }
    
    public private(set) lazy var itemChangedPublisher: AnyPublisher<ChangedContent, Never> = {
        Deferred { [weak self] in
            guard let self = self else {
                return PassthroughSubject<ChangedContent, Never>()
            }
            if let subject = self.itemChangedSubject {
                return subject
            }
            let subject = PassthroughSubject<ChangedContent, Never>()
            self.itemChangedSubject = subject
            self.observeAll()
            return subject
        }.eraseToAnyPublisher()
    }()
    
    public private(set) lazy var reloadPublisher: AnyPublisher<SKSelectionSequence<Element>, Never> = {
        Deferred { [weak self] in
            guard let self = self else {
                return PassthroughSubject<SKSelectionSequence<Element>, Never>()
            }
            if let subject = self.reloadSubject {
                return subject
            }
            let subject = PassthroughSubject<SKSelectionSequence<Element>, Never>()
            self.reloadSubject = subject
            return subject
        }.eraseToAnyPublisher()
    }()
    
    private var itemChangedSubject: PassthroughSubject<ChangedContent, Never>?
    private var reloadSubject: PassthroughSubject<SKSelectionSequence<Element>, Never>?

    /// 是否让选中的元素是整个序列中唯一的选中 | default: true
    public var isUnique: Bool = true
    public private(set) var store: [Element] = []
    private var cancellables = Set<AnyCancellable>()
    fileprivate var subscribe: AnyCancellable?
    
    /// init
    /// - Parameters:
    ///   - items: 数据组
    ///   - isUnique: 是否保证选中在当前序列中是否唯一 | default: true
    public init(items: [Element] = [],
                isUnique: Bool = true) {
        self.store = items
        self.isUnique = isUnique
    }
    
}

public extension SKSelectionSequence {
    
    var selectedItems: [Element] { store.filter(\.isSelected) }
    var firstSelectedItem: Element? { store.first(where: \.isSelected) }
    var lastSelectedItem: Element? { store.last(where: \.isSelected) }
    
    var selectedIndexs: [Int] { store.enumerated().filter(\.element.isSelected).map(\.offset) }
    var firstSelectedIndex: Int? { store.firstIndex(where: \.isSelected) }
    var lastSelectedIndex: Int? { store.lastIndex(where: \.isSelected) }
    
}

public extension SKSelectionSequence {
    
    func reload(_ elements: [Element]) {
        cancellables.removeAll()
        store.removeAll()
        store = elements
        self.observeAll()
        self.reloadSubject?.send(self)
    }
    
    func append(_ elements: [Element]) {
        store.append(contentsOf: elements)
    }
    
    func append(_ elements: Element...) {
        append(elements)
    }
    
}

public extension SKSelectionSequence {
    
    subscript(_ index: Int) -> Element? {
        return store.indices.contains(index) ? store[index] : nil
    }
    
    func item(at index: Int) -> Element? {
        return store.indices.contains(index) ? store[index] : nil
    }
    
}

public extension SKSelectionSequence {
    
    func insert(at index: Int, _ item: Element) {
        store.insert(item, at: index)
    }
    
    func remove(at index: Int) {
        guard store.indices.contains(index) else { return }
        store.remove(at: index)
    }
    
    func select(at index: Int) {
        guard store.indices.contains(index),
              store[index].select(true) else { return }
        maintainUniqueIfNeed(at: index)
    }
    
    func deselect(at index: Int) {
        guard store.indices.contains(index),
              store[index].select(false) else { return }
    }
    
    func selectAll() {
        store
            .filter { !$0.isSelected }
            .forEach { item in
                item.select(true)
            }
    }
    
    func deselectAll() {
        store
            .filter { $0.isSelected }
            .forEach { item in
                item.select(false)
            }
    }
    
}

private extension SKSelectionSequence {
    
    func observeAll() {
        guard itemChangedSubject != nil else {
            return
        }
        for (offset, item) in self.store.enumerated() {
            self.observe(item, offset: offset)
        }
    }
    
    func observe(_ element: Element, offset: Int) {
        element
            .selectedPublisher
            .dropFirst()
            .sink(receiveValue: { [weak self] flag in
                guard let self = self else { return }
                guard self.store.indices.contains(offset) else { return }
                if self.isUnique, flag {
                    self.maintainUniqueIfNeed(at: offset)
                }
                self.itemChangedSubject?.send(.init(offset: offset, element: element))
            })
            .store(in: &cancellables)
    }
    
    @discardableResult
    func maintainUniqueIfNeed(at index: Int) -> Bool {
        guard isUnique else {
            return false
        }
        var result = false
        store
            .enumerated()
            .filter({ $0.offset != index })
            .map(\.element)
            .filter(\.isSelected)
            .forEach { element in
                element.select(false)
                result = true
            }
        return result
    }
    
}

public extension SKSelectionSequence where Element: Equatable {
    
    func removeAll(_ item: Element) {
        store = store.filter({ $0 != item })
    }
    
    func removeFirst(_ item: Element) {
        guard let index = store.firstIndex(of: item) else { return }
        remove(at: index)
    }
    
    func removeLast(_ item: Element) {
        guard let index = store.lastIndex(of: item) else { return }
        remove(at: index)
    }
    
    func contains(_ item: Element) -> Bool {
        store.contains(item)
    }
    
    func selectFirst(_ element: Element?) {
        guard let element = element,
              let index = store.firstIndex(where: { $0 == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectLast(_ element: Element?) {
        guard let element = element,
              let index = store.lastIndex(where: { $0 == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectAll(_ element: Element?) {
        guard let element = element else {
            return
        }
        store
            .enumerated()
            .filter { (offset, item) in
                item == element
            }
            .map(\.offset)
            .forEach { index in
                select(at: index)
            }
    }
    
    func deselectFirst(_ element: Element?) {
        guard let element = element,
              let index = store.firstIndex(where: { $0 == element }) else {
            return
        }
        deselect(at: index)
    }
    
    func deselectLast(_ element: Element?) {
        guard let element = element,
              let index = store.lastIndex(where: { $0 == element }) else {
            return
        }
        deselect(at: index)
    }
    
    func deselectAll(_ element: Element?) {
        guard let element = element else {
            return
        }
        store
            .enumerated()
            .filter { (offset, item) in
                item == element
            }
            .map(\.offset)
            .forEach { index in
                deselect(at: index)
            }
    }
    
}


public extension SKSelectionSequence where Element: RawRepresentable, Element.RawValue: Equatable {
    
    func removeAll(_ item: Element.RawValue?) {
        store = store.filter({ $0.rawValue != item })
    }
    
    func removeFirst(_ item: Element.RawValue?) {
        guard let index = store.firstIndex(where: { $0.rawValue == item }) else { return }
        remove(at: index)
    }
    
    func removeLast(_ item: Element.RawValue?) {
        guard let index = store.lastIndex(where: { $0.rawValue == item }) else { return }
        remove(at: index)
    }
    
    func contains(_ item: Element.RawValue?) -> Bool {
        store.contains(where: { $0.rawValue == item })
    }
    
    func selectFirst(_ element: Element.RawValue?) {
        guard let index = store.firstIndex(where: { $0.rawValue == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectLast(_ element: Element.RawValue?) {
        guard let index = store.lastIndex(where: { $0.rawValue == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectAll(_ element: Element.RawValue?) {
        guard let element = element else {
            return
        }
        store
            .enumerated()
            .filter { (offset, item) in
                item.rawValue == element
            }
            .map(\.offset)
            .forEach { index in
                select(at: index)
            }
    }
    
    func deselectFirst(_ element: Element.RawValue?) {
        guard let index = store.firstIndex(where: { $0.rawValue == element }) else {
            return
        }
        deselect(at: index)
    }
    
    func deselectLast(_ element: Element.RawValue?) {
        guard let index = store.lastIndex(where: { $0.rawValue == element }) else {
            return
        }
        deselect(at: index)
    }
    
    func deselectAll(_ element: Element.RawValue?) {
        guard let element = element else {
            return
        }
        store
            .enumerated()
            .filter { (offset, item) in
                item.rawValue == element
            }
            .map(\.offset)
            .forEach { index in
                deselect(at: index)
            }
    }
    
}
