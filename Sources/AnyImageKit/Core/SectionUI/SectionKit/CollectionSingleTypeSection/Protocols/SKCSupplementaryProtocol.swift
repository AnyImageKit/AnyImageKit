//
//  File.swift
//  
//
//  Created by linhey on 2022/8/19.
//

import UIKit

public protocol SKCSupplementaryProtocol {
    associatedtype View: SKLoadViewProtocol & SKConfigurableView & UICollectionReusableView
    var kind: SKSupplementaryKind { get }
    var type: View.Type { get }
    var config: ((View) -> Void)? { get }
    var size: (_ limitSize: CGSize) -> CGSize { get }
}


public extension SKCSupplementaryProtocol {
    
    func dequeue(from sectionView: UICollectionView, indexPath: IndexPath) -> View {
        let view = sectionView.dequeueReusableSupplementaryView(ofKind: kind.rawValue,
                                                                withReuseIdentifier: View.identifier,
                                                                for: indexPath) as! View
        config?(view)
        return view
    }
    
}
