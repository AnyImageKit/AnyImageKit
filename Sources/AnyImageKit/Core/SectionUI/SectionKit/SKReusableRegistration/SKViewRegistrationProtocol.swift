//
//  File.swift
//  
//
//  Created by linhey on 2022/8/17.
//

import Foundation

public protocol SKViewRegistrationProtocol {
    associatedtype View: SKLoadViewProtocol & SKConfigurableView
    var indexPath: IndexPath? { get set }
    var model: View.Model { get }
    var type: View.Type { get }
}

extension SKViewRegistrationProtocol {
    
    func preferredSize(limit size: CGSize) -> CGSize {
        View.preferredSize(limit: size, model: model)
    }
    
}
