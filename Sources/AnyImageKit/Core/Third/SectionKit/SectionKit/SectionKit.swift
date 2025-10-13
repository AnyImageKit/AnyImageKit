//
//  SectionKit.swift
//  SectionKit2
//
//  Created by linhey on 2023/5/24.
//

import Foundation
import UIKit

public class SKSectionKit {
    
    public static var shared = SKSectionKit()
    
    public var options = Options()
    
    public struct Options {
        /// 当承载视图 size 为0时禁用刷新
        @available(*, deprecated, message: "已不再使用")
        public var disableReloadWhenViewSizeIsZero = true
    }
    
}

public class SKWrapper<Base: SKCompatible> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol SKCompatible: AnyObject {}

public extension SKCompatible {
    var sk: SKWrapper<Self> { return SKWrapper(self) }
    static var sk: SKWrapper<Self>.Type { return SKWrapper<Self>.self }
}

extension UIView: SKCompatible {}