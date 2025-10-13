//
//  SKBinding.swift
//  SectionUI
//
//  Created by linhey on 2023/3/6.
//

import Foundation
import Combine

@propertyWrapper
public struct SKBinding<Value> {
    
    // 包装的值
    public var wrappedValue: Value {
        get { _get() }
        nonmutating set {
            for item in _set {
                item(newValue)
            }
            if !_set.isEmpty {
                self.changedSubject.send(newValue)
            }
        }
    }

    // 返回 SKBinding 的实例
    public var projectedValue: SKBinding<Value> { self }
    public var changedPublisher: AnyPublisher<Value, Never> { changedSubject.eraseToAnyPublisher() }
    public var isSetable: Bool { !_set.isEmpty }

    private let _get: () -> Value
    private let _set: [(Value) -> Void]
    private let changedSubject = PassthroughSubject<Value, Never>()

    // 初始化方法，接受一个 getter 和 setter
    public init(get: @escaping () -> Value, set: ((Value) -> Void)? = nil) {
        if let set = set {
            self.init(get: get, set: [set])
        } else {
            self.init(get: get, set: [])
        }
    }
    
    private init(get: @escaping () -> Value, set: [(Value) -> Void]) {
        self._get = get
        self._set = set
    }
    
}

public extension SKBinding {
    
    // 创建一个常量绑定
    static func constant(_ value: Value) -> SKBinding<Value> {
        .init(get: { value }, set: { _ in })
    }
    
    static func constant(_ value: @escaping () -> Value) -> SKBinding<Value> {
        .init(get: value, set: { _ in })
    }
    
}

public extension SKBinding {
    
    // 从一个现有的绑定创建一个新的绑定
    init(_ source: CurrentValueSubject<Value, Never>) {
        self.init(get: { source.value }, set: { source.send($0) })
    }
    
    // 从一个现有的绑定创建一个新的绑定
    init(_ source: CurrentValueSubject<Value?, Never>, default: Value) {
        self.init(get: { source.value ?? `default` }, set: { source.send($0) })
    }
    
}

public extension SKBinding {
    
    // 从一个现有的绑定创建一个新的绑定
    init(_ source: SKBinding<Value>) {
        self.init(get: source._get, set: source._set)
    }
    
    // 从一个对象的 keyPath 创建一个绑定
    init<Root>(on object: Root, keyPath: ReferenceWritableKeyPath<Root, Value>) {
        self.init {
            object[keyPath: keyPath]
        } set: { value in
            object[keyPath: keyPath] = value
        }
    }
    
    init<Root>(on object: Root, keyPath: ReferenceWritableKeyPath<Root, Value>, default: Value) where Root: AnyObject {
        self.init { [weak object] in
            object?[keyPath: keyPath] ?? `default`
        } set: { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
    
    init<Root>(on object: Root, keyPath: ReferenceWritableKeyPath<Root, Value?>, default: Value) where Root: AnyObject {
        self.init { [weak object] in
            object?[keyPath: keyPath] ?? `default`
        } set: { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
    
}
