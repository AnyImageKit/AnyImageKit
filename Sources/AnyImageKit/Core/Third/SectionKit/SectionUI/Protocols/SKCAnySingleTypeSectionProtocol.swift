//
//  SKCAnySingleTypeSectionProtocol.swift
//  Pods
//
//  Created by linhey on 5/28/25.
//

import UIKit
import Combine

public protocol SKCAnySingleTypeSectionProtocol: SKCRawSectionProtocol, SKCSectionLayoutPluginProtocol where RawSection: SKCSingleTypeSection<Cell> {
    associatedtype Cell: UICollectionViewCell & SKLoadViewProtocol & SKConfigurableView
}

public extension SKCAnySingleTypeSectionProtocol {
    
    var sectionInset: UIEdgeInsets {
        get { rawSection.sectionInset }
        set { rawSection.sectionInset = newValue }
    }
    
    var sectionInjection: SKCSectionInjection? {
        get { rawSection.sectionInjection }
        set { rawSection.sectionInjection = newValue }
    }

    var plugins: [SKCSectionLayoutPlugin] {
        get { rawSection.plugins }
        set { rawSection.plugins = newValue }
    }
    
    @discardableResult
    func pin(options: SKCSectionPinOptions) -> AnyCancellable {
        rawSection.pin(options: options)
    }
    
}

public extension SKCAnySingleTypeSectionProtocol {
    
    @discardableResult
    func onCellAction(_ kind: SKCCellActionType, block: @escaping RawSection.CellActionBlock) -> Self {
        rawSection.onCellAction(kind, block: block)
        return self
    }
    
}
