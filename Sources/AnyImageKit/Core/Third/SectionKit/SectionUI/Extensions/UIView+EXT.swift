//
//  File.swift
//  SectionKit
//
//  Created by linhey on 1/13/25.
//

import UIKit

/// 一个用于遍历响应链的序列
public struct ResponderSequence: Sequence {
    
    public let start: UIResponder
    
    public init(start: UIResponder) {
        self.start = start
    }
    
    public func makeIterator() -> Iterator {
        Iterator(current: start)
    }
    
    @MainActor
    public func first<T: UIResponder>(of: T.Type) -> T? {
        for current in self {
            if let item = current as? T {
                return item
            }
        }
        return nil
    }
    
    public struct Iterator: @preconcurrency IteratorProtocol {
        public var current: UIResponder?
        
        @MainActor
        public mutating func next() -> UIResponder? {
            defer { current = current?.next }
            return current
        }
    }
}

extension UIResponder: SKCompatible {}

@MainActor
public extension SKWrapper where Base: UIResponder {
    
    var viewController: UIViewController? {
        responderSequence.first(of: UIViewController.self)
    }
    
    var responderSequence: ResponderSequence {
        ResponderSequence(start: base)
    }
    
}

extension UIViewController: SKCompatible {}

@MainActor
public extension SKWrapper where Base: UIViewController {
    
    /// 获取当前显示控制器
    public static var current: UIViewController? {
        
        func find(rawVC: UIViewController) -> UIViewController {
            switch rawVC {
            case let vc where vc.presentedViewController != nil:
                return find(rawVC: vc.presentedViewController!)
            case let nav as UINavigationController:
                guard let vc = nav.visibleViewController else { return rawVC }
                return find(rawVC: vc)
            case let tab as UITabBarController:
                guard let vc = tab.selectedViewController else { return rawVC }
                return find(rawVC: vc)
            default:
                return rawVC
            }
        }
        
        let keyWindow = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?
            .windows
            .first(where: \.isKeyWindow)
        
        guard let controller = keyWindow?.rootViewController else {
            return nil
        }
        
        return find(rawVC: controller)
    }
    
}
