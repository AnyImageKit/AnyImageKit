//
//  SKCSectionActionProtocol.swift
//  OpenClass
//
//  Created by linhey on 2023/6/20.
//

import UIKit

/// SKCWrapper
public extension SKCSectionActionProtocol {
    
    func dequeue<V: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol>(at row: Int, for type: V.Type) -> V {
        _dequeue(at: row)
    }
    func dequeue<V: UICollectionReusableView & SKConfigurableView & SKLoadViewProtocol>(kind: SKSupplementaryKind, for type: V.Type) -> V {
        _dequeue(kind: kind)
    }
    func register<V: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol>(_ cell: V.Type) {
        _register(V.self)
    }
    func register<V: UICollectionReusableView & SKConfigurableView & SKLoadViewProtocol>(_ view: V.Type, for kind: SKSupplementaryKind)  {
        _register(V.self, for: kind)
    }
    
    func dequeue<V: SKConfigurableView & SKLoadViewProtocol>(at row: Int, for type: V.Type) -> SKCWrapperCell<V> {
        _dequeue(at: row)
    }
    func dequeue<V: SKConfigurableView & SKLoadViewProtocol>(kind: SKSupplementaryKind, for type: V.Type) -> SKCWrapperReusableView<V> {
        _dequeue(kind: kind)
    }
    func register<V: SKConfigurableView & SKLoadViewProtocol>(_ cell: V.Type) {
        _register(SKCWrapperCell<V>.self)
    }
    func register<V: SKConfigurableView & SKLoadViewProtocol>(_ view: V.Type, for kind: SKSupplementaryKind) {
        _register(SKCWrapperReusableView<V>.self, for: kind)
    }
    
}
