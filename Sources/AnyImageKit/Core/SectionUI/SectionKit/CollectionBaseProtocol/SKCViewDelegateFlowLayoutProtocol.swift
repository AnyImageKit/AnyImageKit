//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import UIKit

public protocol SKCViewDelegateFlowLayoutProtocol: SKCDelegateProtocol {
    
    func itemSize(at row: Int) -> CGSize
    
    var headerView: UICollectionReusableView? { get }
    var footerView: UICollectionReusableView? { get }
    
    var headerSize: CGSize { get }
    var footerSize: CGSize { get }
    
    var sectionInset: UIEdgeInsets { get }
    
    var minimumLineSpacing: CGFloat { get }
    var minimumInteritemSpacing: CGFloat { get }
    
}

public extension SKCViewDelegateFlowLayoutProtocol {
    
    var headerView: UICollectionReusableView? { nil }
    var footerView: UICollectionReusableView? { nil }
    
    var headerSize: CGSize { .zero }
    var footerSize: CGSize { .zero }
    
    var minimumLineSpacing: CGFloat { 0 }
    var minimumInteritemSpacing: CGFloat { 0 }
    
    var sectionInset: UIEdgeInsets { .zero }
    
}
