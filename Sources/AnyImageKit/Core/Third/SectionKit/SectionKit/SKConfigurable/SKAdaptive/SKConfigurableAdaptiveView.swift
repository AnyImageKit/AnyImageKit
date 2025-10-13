//
//  File.swift
//  
//
//  Created by linhey on 2023/3/9.
//

#if canImport(UIKit)
import UIKit

public protocol SKConfigurableAdaptiveView: SKConfigurableView {
    associatedtype AdaptiveView: UIView
    static var adaptive: SKAdaptive<AdaptiveView, Model> { get }
}

public extension SKConfigurableAdaptiveView {
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        adaptive.preferredSize(limit: size, model: model)
    }
    
}


#endif
