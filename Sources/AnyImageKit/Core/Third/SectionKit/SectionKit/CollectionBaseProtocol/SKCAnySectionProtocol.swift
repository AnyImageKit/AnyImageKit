//
//  SKCAnySectionProtocol.swift
//  SectionKit
//
//  Created by linhey on 5/22/25.
//

import UIKit
import Foundation

public protocol SKCAnySectionProtocol: SKCSectionActionProtocol {
    var section: SKCSectionProtocol { get }
    var objectIdentifier: ObjectIdentifier { get }
}
 
public extension SKCAnySectionProtocol {
    var itemCount: Int { section.itemCount }
    var sectionInjection: SKCSectionInjection? {
        get { section.sectionInjection }
        set { section.sectionInjection = newValue }
    }
    func config(sectionView: UICollectionView) {
        section.config(sectionView: sectionView)
    }
    var objectIdentifier: ObjectIdentifier { .init(section) }
}

public extension SKCAnySectionProtocol where Self: SKCSectionProtocol {
    var section: SKCSectionProtocol { self }
}
