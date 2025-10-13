//
//  File.swift
//
//
//  Created by linhey on 2023/4/25.
//

#if canImport(UIKit)
import UIKit

public struct SKAdaptiveFittingPriority {
    
    public let horizontal: UILayoutPriority
    public let vertical: UILayoutPriority
    
    public init(horizontal: UILayoutPriority, vertical: UILayoutPriority) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
}

public protocol SKAdaptiveProtocol {
    associatedtype AdaptiveView: UIView
    associatedtype Model
    var direction: SKLayoutDirection { get }
    var view: AdaptiveView { get }
    var insets: UIEdgeInsets { get }
    var fittingPriority: SKAdaptiveFittingPriority { get }
    var config: (_ view: AdaptiveView, _ size: CGSize, _ model: Model) -> Void  { get }
    var content: (_ view: AdaptiveView) -> UIView? { get }
}

extension SKAdaptiveProtocol {

    @inline(__always)
    private func _preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model = model else { return .zero }
        var size = size
        config(view, size, model)
        size = view.systemLayoutSizeFitting(view.bounds.size,
                                            withHorizontalFittingPriority: fittingPriority.horizontal,
                                            verticalFittingPriority: fittingPriority.vertical)
        if let content = content(view) {
            view.layoutIfNeeded()
            let contentSize = content.frame.size
            if fittingPriority.horizontal == .fittingSizeLevel {
                size.width = contentSize.width
            }
            if fittingPriority.vertical == .fittingSizeLevel {
                size.height = contentSize.height
            }
        }
        
        let result = CGSize(width: size.width + insets.left + insets.right,
                            height: size.height + insets.top + insets.bottom)
        
        if result.width == 0 || result.height == 0 {
            return .zero
        }
        return result
    }
    
    func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model = model else { return .zero }
        #if DEBUG
        return SKPerformance.shared.duration("[SKAdaptive] \(AdaptiveView.self)") {
            _preferredSize(limit: size, model: model)
        }
        #else
        return _preferredSize(limit: size, model: model)
        #endif
    }
    
}

public struct SKAdaptive<AdaptiveView: UIView, Model>: SKAdaptiveProtocol {
    
    // 适配方向
    public let direction: SKLayoutDirection
    // 适配的视图
    public let view: AdaptiveView
    // 适配视图内容视图的keyPath
    public var content: (_ view: AdaptiveView) -> UIView?
    // 视图周围的inset
    public let insets: UIEdgeInsets
    // 视图适配优先级
    public let fittingPriority: SKAdaptiveFittingPriority
    // 配置视图的闭包
    public let config: (_ view: AdaptiveView, _ size: CGSize, _ model: Model) -> Void
    
    public init(view: AdaptiveView = .init(),
                direction: SKLayoutDirection = .vertical,
                insets: UIEdgeInsets = .zero,
                fittingPriority: SKAdaptiveFittingPriority? = nil,
                content: ((_ view: AdaptiveView) -> UIView?)? = nil,
                config: @escaping (_ view: AdaptiveView, _ size: CGSize, _ model: Model) -> Void) {
        self.view = view
        self.direction = direction
        if let content {
            self.content = { view in
                content(view)
            }
        } else {
            self.content = { _ in
                nil
            }
        }
        
        self.insets = insets
        self.config = config
        if let fittingPriority = fittingPriority {
            self.fittingPriority = fittingPriority
        } else {
            switch direction {
            case .horizontal:
                self.fittingPriority = .init(horizontal: .fittingSizeLevel, vertical: .required)
            case .vertical:
                self.fittingPriority = .init(horizontal: .required, vertical: .fittingSizeLevel)
            }
        }
    }
    
    public init<T: UIView>(view: AdaptiveView = .init(),
                           direction: SKLayoutDirection = .vertical,
                           content: KeyPath<AdaptiveView, T>? = nil,
                           insets: UIEdgeInsets = .zero,
                           fittingPriority: SKAdaptiveFittingPriority? = nil,
                           config: @escaping (_ view: AdaptiveView, _ size: CGSize, _ model: Model) -> Void) {
        self.init(view: view, direction: direction, insets: insets, fittingPriority: fittingPriority, content: { view in
            if let content {
                return view[keyPath: content]
            }
            return nil
        }, config: config)
    }
    
    public init<T: UIView>(view: AdaptiveView = .init(),
                           direction: SKLayoutDirection = .vertical,
                           content: KeyPath<AdaptiveView, T>? = nil,
                           insets: UIEdgeInsets = .zero,
                           fittingPriority: SKAdaptiveFittingPriority? = nil,
                           afterConfig: ((_ view: AdaptiveView, _ model: Model) -> Void)? = nil) where AdaptiveView: SKConfigurableView, AdaptiveView.Model == Model {
        self.init(view: view, direction: direction, content: content, insets: insets) { view, size, model in
            switch direction {
            case .horizontal:
                view.bounds.size = .init(width: 0, height: size.height)
            case .vertical:
                view.bounds.size = .init(width: size.width, height: 0)
            }
            view.config(model)
            afterConfig?(view, model)
        }
    }
}
#endif
