//
//  SKCRawSectionProtocol 2.swift
//  Pods
//
//  Created by linhey on 5/22/25.
//

import Foundation

public protocol SKCRawSectionProtocol: SKCAnySectionProtocol {
    associatedtype RawSection
    typealias RawSectionStyleBlock = (_ section: RawSection) -> Void
    var rawSection: RawSection { get }
}

/// 配置当前 section 样式
public extension SKCRawSectionProtocol {
    /// 配置当前 section 样式
    /// - Parameter item: 回调
    /// - Returns: self
    @discardableResult
    func setSectionStyle(_ item: @escaping RawSectionStyleBlock) -> Self {
        item(rawSection)
        return self
    }
    
    @discardableResult
    func setSectionStyle<Value>(_ path: ReferenceWritableKeyPath<RawSection, Value>, _ value: Value) -> Self {
        rawSection[keyPath: path] = value
        return self
    }
    
    @discardableResult
    func setSectionStyle<Value>(_ path: ReferenceWritableKeyPath<RawSection, Value?>, _ value: Value?) -> Self {
        rawSection[keyPath: path] = value
        return self
    }
    
    @discardableResult
    func setSectionStyle<Value>(_ paths: [ReferenceWritableKeyPath<RawSection, Value>], _ value: Value) -> Self {
        for path in paths {
            rawSection[keyPath: path] = value
        }
        return self
    }
    
    @discardableResult
    func setSectionStyle<Value>(_ paths: [ReferenceWritableKeyPath<RawSection, Value?>], _ value: Value?) -> Self {
        for path in paths {
            rawSection[keyPath: path] = value
        }
        return self
    }
}
