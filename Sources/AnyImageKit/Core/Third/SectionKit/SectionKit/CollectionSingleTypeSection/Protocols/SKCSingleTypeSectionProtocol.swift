//
//  File.swift
//  
//
//  Created by linhey on 2022/8/18.
//

#if canImport(UIKit)
import UIKit

public protocol SKCSingleTypeSectionProtocol: SKCSectionProtocol,
                                              SKCViewDataSourcePrefetchingProtocol,
                                              SKSafeSizeProviderProtocol {
    
    associatedtype Cell: UICollectionViewCell & SKConfigurableView
    typealias Model = Cell.Model
    var models: [Model] { get }

}

#endif
