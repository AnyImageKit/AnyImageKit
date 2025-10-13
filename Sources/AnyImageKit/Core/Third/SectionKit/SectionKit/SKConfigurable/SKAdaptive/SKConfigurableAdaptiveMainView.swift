//
//  ConfigurableAdaptiveMainView.swift
//  
//
//  Created by linhey on 2023/8/9.
//

#if canImport(UIKit)
import UIKit

/** 适配主视图协议, 以当前视图作为 AdaptiveView 进行内容调整
 
 final class CustomCell: UIView, SKConfigurableAdaptiveMainView {
     typealias Model = Void
     static var adaptive: SpecializedAdaptive = .init()
 }
 
 */
public protocol SKConfigurableAdaptiveMainView: SKConfigurableAdaptiveView where AdaptiveView == Self {
    // 关联类型别名,用于适配视图结构体
    typealias SpecializedAdaptive = SKAdaptive<AdaptiveView, Model>
    // 要求提供适配视图结构体
    static var adaptive: SpecializedAdaptive { get }
}


public protocol SKConfigurableAutoAdaptiveView: UIView, SKConfigurableView {
    static func adaptive() -> SKAdaptive<Self, Model>
}

public extension SKConfigurableAutoAdaptiveView {
    
    static func adaptive() -> SKAdaptive<Self, Model> {
        .init()
    }

}

public extension SKConfigurableAutoAdaptiveView {
            
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        let key = SKAdaptive<Self, Model>.self
        if let item = SKConfigurableAdaptiveAutoCache.shared[key] as? SKAdaptive<Self, Model> {
            return item.preferredSize(limit: size, model: model)
        } else {
            let item = adaptive()
            SKConfigurableAdaptiveAutoCache.shared[key] = item
            return item.preferredSize(limit: size, model: model)
        }
    }
    
}

public class SKConfigurableAdaptiveAutoCache {
    
    public static let shared = SKConfigurableAdaptiveAutoCache()
    public var cache = [ObjectIdentifier: any SKAdaptiveProtocol]()
    
    public subscript<T>(_ type: T.Type) -> (any SKAdaptiveProtocol)? {
        get { cache[ObjectIdentifier(type)] }
        set { cache[ObjectIdentifier(type)] = newValue }
    }
    
}


#endif


