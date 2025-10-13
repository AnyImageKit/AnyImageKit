//
//  File.swift
//
//
//  Created by linhey on 2022/3/14.
//

import Foundation

// 定义了可配置视图协议,组合可配置模型,布局和UIView协议
public protocol SKExistModelView: SKExistModelProtocol & SKConfigurableLayoutProtocol { }
public protocol SKConfigurableView: SKConfigurableModelProtocol & SKConfigurableLayoutProtocol {}

public extension SKConfigurableView where Model == Void {
    
    func config(_ model: Model) {}
    
}

// 支持通过RawRepresentable配置模型
public extension SKConfigurableView {
    
    func config<T: RawRepresentable>(_ model: T) where Model == T.RawValue {
        config(model.rawValue)
    }
    
}
