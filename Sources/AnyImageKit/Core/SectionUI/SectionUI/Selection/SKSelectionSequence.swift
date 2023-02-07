//
//  File.swift
//  
//
//  Created by linhey on 2022/9/9.
//

import Foundation

public class SKSelectionSequence<Element: SKSelectionProtocol>: SKSelectionSequenceProtocol {
    
    public var selectableElements: [Element]
    /// 是否让选中的元素是整个序列中唯一的选中 | default: true
    public var isUnique: Bool = true
    /// 是否需要支持反选操作 | default: false
    public var needInvert: Bool = false
    
    public init(elements: [Element] = [],
                isUnique: Bool = true,
                needInvert: Bool = false) {
        self.selectableElements = elements
        self.isUnique = isUnique
        self.needInvert = needInvert
    }
    
}

public extension SKSelectionSequence {
    
    func append(_ elements: [Element]) {
        selectableElements.append(contentsOf: elements)
    }
    
    func append(_ elements: Element...) {
        append(elements)
    }
    
    func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        try selectableElements.contains(where: predicate)
    }
    
}

public extension SKSelectionSequence {
    
    func select(at index: Int) {
        select(at: index, isUnique: isUnique, needInvert: needInvert)
    }
    
}

public extension SKSelectionSequence {
    
    func contains<T: Equatable>(_ element: T) -> Bool where Element == SKSelectionWrapper<T> {
        selectableElements.contains { wrapper in
            wrapper.wrappedValue == element
        }
    }
    
    func selectFirst<T: Equatable>(_ element: T?) where Element == SKSelectionWrapper<T> {
        guard let element = element,
              let index = selectableElements.firstIndex(where: { $0.wrappedValue == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectLast<T: Equatable>(_ element: T?) where Element == SKSelectionWrapper<T> {
        guard let element = element,
              let index = selectableElements.lastIndex(where: { $0.wrappedValue == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectAll<T: Equatable>(_ element: T?) where Element == SKSelectionWrapper<T> {
        guard let element = element else {
            return
        }
        selectedElements
            .enumerated()
            .filter { (offset, item) in
                item.wrappedValue == element
            }
            .map(\.offset)
            .forEach { index in
                select(at: index)
            }
    }
    
    func deselectFirst<T: Equatable>(_ element: T?) where Element == SKSelectionWrapper<T> {
        guard let element = element,
              let index = selectableElements.firstIndex(where: { $0.wrappedValue == element }) else {
            return
        }
        deselect(at: index)
    }
    
    func deselectLast<T: Equatable>(_ element: T?) where Element == SKSelectionWrapper<T> {
        guard let element = element,
              let index = selectableElements.lastIndex(where: { $0.wrappedValue == element }) else {
            return
        }
        deselect(at: index)
    }
    
    func deselectAll<T: Equatable>(_ element: T?) where Element == SKSelectionWrapper<T> {
        guard let element = element else {
            return
        }
        selectedElements
            .enumerated()
            .filter { (offset, item) in
                item.wrappedValue == element
            }
            .map(\.offset)
            .forEach { index in
                deselect(at: index)
            }
    }
    
}

public extension SKSelectionSequence where Element: Equatable {
    
    func contains(_ element: Element) -> Bool {
        selectableElements.contains(element)
    }
    
    func selectFirst(_ element: Element?) {
        guard let element = element,
              let index = selectableElements.firstIndex(where: { $0 == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectLast(_ element: Element?) {
        guard let element = element,
              let index = selectableElements.lastIndex(where: { $0 == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectAll(_ element: Element?) {
        guard let element = element else {
            return
        }
        selectedElements
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
              let index = selectableElements.firstIndex(where: { $0 == element }) else {
            return
        }
        deselect(at: index)
    }
    
    func deselectLast(_ element: Element?) {
        guard let element = element,
              let index = selectableElements.lastIndex(where: { $0 == element }) else {
            return
        }
        deselect(at: index)
    }
    
    func deselectAll(_ element: Element?) {
        guard let element = element else {
            return
        }
        selectedElements
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
