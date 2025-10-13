//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

#if canImport(UIKit)
import UIKit

public typealias SKCBaseSectionProtocol = SKCSectionActionProtocol & SKCDataSourceProtocol & SKCDelegateProtocol
public typealias SKCSectionProtocol = SKCBaseSectionProtocol & SKCViewDelegateFlowLayoutProtocol & SKCAnySectionProtocol
public extension SKCDataSourceProtocol where Self: SKCViewDelegateFlowLayoutProtocol {
    
    func supplementary(kind: SKSupplementaryKind, at row: Int) -> UICollectionReusableView? {
        switch kind {
        case .header:
            return headerView
        case .footer:
            return footerView
        case .cell, .custom:
            return nil
        }
    }
    
}
#endif
