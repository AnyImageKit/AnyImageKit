//
//  File.swift
//  
//
//  Created by linhey on 2022/8/18.
//

import UIKit

public protocol SKCSingleTypeSectionProtocol: SKCDataSourceProtocol,
                                              SKCSectionActionProtocol,
                                              SKCViewDataSourcePrefetchingProtocol,
                                              SKCViewDelegateFlowLayoutProtocol,
                                              SKSafeSizeProviderProtocol {
    
    associatedtype Cell: UICollectionViewCell & SKConfigurableView
    typealias Model = Cell.Model
    var models: [Model] { get }

}
