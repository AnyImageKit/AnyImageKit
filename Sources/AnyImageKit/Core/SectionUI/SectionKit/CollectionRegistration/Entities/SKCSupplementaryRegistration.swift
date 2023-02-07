//
//  STCollectionReusableViewRegistration.swift
//  
//
//  Created by linhey on 2022/8/15.
//

import UIKit

public extension SKConfigurableView where Self: UICollectionReusableView & SKLoadViewProtocol {
    
    static func registration(_ model: Model, for kind: SKSupplementaryKind) -> SKCSupplementaryRegistration<Self, Int> {
        return .init(kind: kind, model: model, type: Self.self)
    }
    
}

public class SKCSupplementaryRegistration<View: UICollectionReusableView & SKConfigurableView & SKLoadViewProtocol,
                                          ID: Hashable>: SKViewRegistration<View, ID>,
                                                         SKCSupplementaryRegistrationProtocol {
    
    
    public let kind: SKSupplementaryKind
    public var tags: Set<String> = .init()
    
    public var injection: (any SKCRegistrationInjectionProtocol)?
    
    public var viewStyle: ViewInputBlock?
    public var onWillDisplay: VoidBlock?
    public var onEndDisplaying: VoidBlock?
    
    public init(kind: SKSupplementaryKind, model: View.Model, type: View.Type) where ID == Int {
        self.kind = kind
        super.init(model: model, type: type)
    }
    
    public init(kind: SKSupplementaryKind, model: View.Model, type: View.Type, id: KeyPath<View.Model, ID>?) {
        self.kind = kind
        super.init(model: model, type: type, id: id)
    }
    
}
