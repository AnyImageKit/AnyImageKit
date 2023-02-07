//
//  File.swift
//
//
//  Created by linhey on 2022/3/14.
//

#if canImport(CoreGraphics)
import Foundation
import UIKit

public protocol SKConfigurableView: SKConfigurableModelProtocol & SKConfigurableLayoutProtocol & UIView {}

public extension SKConfigurableView where Model == Void {
    
    func config(_ model: Model) {}
    
}

#endif
