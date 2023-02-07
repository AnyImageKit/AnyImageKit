//
//  STCollectionCellRegistration.swift
//  
//
//  Created by linhey on 2022/8/15.
//

import UIKit

public extension SKConfigurableView where Self: UICollectionViewCell & SKLoadViewProtocol {
    
    static func registration(_ model: Model) -> SKCCellRegistration<Self, Int> {
        return .init(model: model, type: Self.self)
    }
    
    static func registration(_ models: [Model]) -> [SKCCellRegistration<Self, Int>] {
        return models.map { model in
                .init(model: model, type: Self.self)
        }
    }
    
}

public class SKCCellRegistration<View: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol, ID: Hashable>: SKViewRegistration<View, ID>, SKCCellRegistrationProtocol {
    
    public let kind: SKSupplementaryKind = .cell
    public var tags: Set<String> = .init()
    
    public var injection: (any SKCRegistrationInjectionProtocol)?

    public var viewStyle: ViewInputBlock?
    public var shouldHighlight: BoolBlock?
    public var shouldSelect: BoolBlock?
    public var shouldDeselect: BoolBlock?
    public var canPerformPrimaryAction: BoolBlock?
    public var canFocus: BoolBlock?
    public var selectionFollowsFocus: BoolBlock?
    public var canEdit: BoolBlock?
    public var shouldBeginMultipleSelectionInteraction: BoolBlock?
    
    public var onHighlight: VoidBlock?
    public var onUnhighlight: VoidBlock?
    public var onSelected: VoidBlock?
    public var onDeselected: VoidBlock?
    public var onPerformPrimaryAction: VoidBlock?
    public var onBeginMultipleSelectionInteraction: VoidBlock?
    
    public var onWillDisplay: VoidBlock?
    public var onEndDisplaying: VoidBlock?
    
    public var shouldSpringLoad: ((UISpringLoadedInteractionContext) -> Bool)?
    
}
