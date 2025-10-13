//
//  SKEventGroup.swift
//  SectionKit
//
//  Created by linhey on 5/22/25.
//

import Foundation

public final class SKEventGroup<Event: Hashable, Element> {
    
    public var store: [Event: [Element]] = [:]
    
    public subscript(_ event: Event) -> [Element] {
        store[event] ?? []
    }
    
}

public extension SKEventGroup {
    
    func removeAll(of key: Event) {
        store[key] = nil
    }
    
    func append(of key: Event, _ element: Element) {
        var items = store[key] ?? []
        items.append(element)
        store[key] = items
    }
    
}
