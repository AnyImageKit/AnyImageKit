//
//  File.swift
//  
//
//  Created by linhey on 2024/3/17.
//

import UIKit

public protocol SKCLayoutDecorationPlugin: AnyObject {
    associatedtype View: SKCDecorationView
    typealias ActionBlock = (_ context: SKCLayoutDecoration.Context<View>) -> Void
    var id: String { get }
    var from: SKCLayoutDecoration.Item { get set }
    var to: SKCLayoutDecoration.Item? { get }
    var viewType: View.Type { get }
    var insets: UIEdgeInsets { get }
    var zIndex: Int? { get set }
    var index: Int? { get set }
    var actions: [SKCSupplementaryActionType: [ActionBlock]] { get set }
}

public extension SKCLayoutDecorationPlugin {
    
    func indexRange(_ view: UICollectionView) -> ClosedRange<Int>? {
        if let from = from.index.wrappedValue, let to = to?.index.wrappedValue {
            return min(from, to)...max(to, to)
        } else if let from = from.index.wrappedValue {
            return from...from
        } else {
            return nil
        }
    }
    
    func apply(to layout: UICollectionViewFlowLayout) {
        if let nib = viewType.nib {
            layout.register(nib, forDecorationViewOfKind: viewType.identifier)
        } else {
            layout.register(viewType.self, forDecorationViewOfKind: viewType.identifier)
        }
    }

    @discardableResult
    func onAction<T>(_ kind: SKCSupplementaryActionType,
                     on keyPath: ReferenceWritableKeyPath<SKCLayoutDecoration.Context<View>, T>,
                     _ value: T) -> Self {
        return self.onAction(kind) { context in
            context[keyPath: keyPath] = value
        }
    }
    
    @discardableResult
    func onAction(_ kind: SKCSupplementaryActionType, block: @escaping ActionBlock) -> Self {
        if actions[kind] == nil {
            actions[kind] = []
        }
        actions[kind]?.append(block)
        return self
    }
    
    func apply(kind: SKCSupplementaryActionType,
               identifier: String,
               at indexPath: IndexPath,
               view: UICollectionReusableView) {
        guard from.index.wrappedValue == indexPath.section,
              self.index == indexPath.item,
              viewType.identifier == identifier,
              let actions = actions[kind],
              !actions.isEmpty,
              let view = view as? View else {
            return
        }
        let context = SKCLayoutDecoration.Context(type: kind,
                                                  kind: .init(rawValue: identifier),
                                                  indexPath: indexPath,
                                                  view: view)
        
        for action in actions {
            action(context)
        }
    }
    
}
