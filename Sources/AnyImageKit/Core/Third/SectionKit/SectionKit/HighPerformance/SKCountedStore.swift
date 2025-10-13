//
//  File.swift
//
//
//  Created by linhey on 2023/7/19.
//

#if canImport(ObjectiveC) && canImport(UIKit)
import ObjectiveC
import Foundation
import CoreFoundation

/// SKCountedStore 是一个计数存储类，用于管理不同 ID 的计数以及相关的触发器。
public class SKCountedStore {
    
    /// 全局触发器类型别名，接收 ID 和当前计数作为参数。
    public typealias GlobalTrigger = (_ id: Int, _ count: Int) -> Void
    
    /// 触发器结构体，用于定义特定条件下的回调。
    public struct Trigger {
        /// 触发条件，当计数满足此条件时触发回调。
        public let when: (Int) -> Bool
        /// 触发时执行的回调闭包。
        public let callback: () -> Void
        
        /// 触发器初始化方法。
        /// - Parameters:
        ///   - when: 触发条件闭包。
        ///   - callback: 触发时执行的闭包。
        public init(when: @escaping (Int) -> Bool,
                    callback: @escaping () -> Void) {
            self.when = when
            self.callback = callback
        }
    }
    
    /// 缓存字典，存储每个 ID 对应的计数。
    public var cached: [Int: Int] = [:]
    
    /// 触发器字典，存储每个 ID 对应的触发器数组。
    public var triggers: [Int: [Trigger]] = [:]
    
    /// 全局触发器数组，所有计数更新时都会调用这些触发器。
    public var globalTriggers: [GlobalTrigger] = []
    
    /// 计数的最大值，超过此值计数将不再增加。
    public var maxCount: Int = .max

    /// SKCountedStore 的初始化方法。
    public init() {}
    
}

public extension SKCountedStore {
    
    /// 添加一个全局触发器，当任何 ID 的计数更新时都会调用该触发器。
    /// - Parameter global: 全局触发器闭包。
    func trigger(global: @escaping GlobalTrigger) {
        self.globalTriggers.append(global)
    }
    
    /// 为指定的 ID 添加一个触发器，当计数等于指定值时触发回调。
    /// - Parameters:
    ///   - id: 触发器关联的 ID。
    ///   - when: 触发的计数值，默认为 1。
    ///   - callback: 触发时执行的闭包。
    func trigger(of id: Int, when: Int = 1, callback: @escaping () -> Void) {
        trigger(of: id, when: { $0 == when }, callback: callback)
    }
    
    /// 为指定的 ID 添加一个触发器，当计数满足条件时触发回调。
    /// - Parameters:
    ///   - id: 触发器关联的 ID。
    ///   - when: 触发条件闭包。
    ///   - callback: 触发时执行的闭包。
    func trigger(of id: Int, when: @escaping (Int) -> Bool, callback: @escaping () -> Void) {
        trigger(of: id, trigger: Trigger(when: when, callback: callback))
    }
    
    /// 为指定的 ID 添加一个触发器。
    /// - Parameters:
    ///   - id: 触发器关联的 ID。
    ///   - trigger: 触发器实例。
    func trigger(of id: Int, trigger: Trigger) {
        if triggers[id] == nil {
            triggers[id] = [trigger]
        } else {
            triggers[id]?.append(trigger)
        }
    }
    
    /// 更新指定 ID 的计数，并触发相关的触发器。
    /// - Parameters:
    ///   - id: 要更新的 ID。
    ///   - count: 增加的计数值，默认为 1。
    /// - Returns: 更新后的计数值。
    @discardableResult
    func update(by id: Int, count: Int = 1) -> Int {
       
        // 获取当前 ID 的计数，若不存在则初始化为 0
        var cachedCount = cached[id] ?? 0
        
        // 如果当前计数小于最大值，则增加计数
        if cachedCount < maxCount {
            cachedCount += count
            cached[id] = cachedCount
        }
        
        // 检查并触发与 ID 相关的触发器
        if let triggers = triggers[id] {
            for trigger in triggers where trigger.when(cachedCount) {
                trigger.callback()
            }
        }
        
        // 触发所有全局触发器
        for trigger in globalTriggers {
            trigger(id, cachedCount)
        }
        
        return cachedCount
    }
    
    /// 重置指定 ID 的计数为 0。
    /// - Parameter id: 要重置的 ID。
    func reset(by id: Int) {
        cached[id] = 0
    }
    
    /// 重置所有 ID 的计数。
    func resetAll() {
        cached.removeAll()
    }
    
}

public extension SKCountedStore {
    
    /// 为指定的模型添加一个触发器，当计数等于指定值时触发回调。
    /// - Parameters:
    ///   - model: 关联的模型，必须遵循 Hashable 协议。
    ///   - when: 触发的计数值，默认为 1。
    ///   - callback: 触发时执行的闭包。
    func trigger<Model: Hashable>(of model: Model, when: Int = 1, callback: @escaping () -> Void) {
        trigger(of: model.hashValue, when: when, callback: callback)
    }
    
    /// 为指定的模型添加一个触发器，当计数满足条件时触发回调。
    /// - Parameters:
    ///   - model: 关联的模型，必须遵循 Hashable 协议。
    ///   - when: 触发条件闭包。
    ///   - callback: 触发时执行的闭包。
    func trigger<Model: Hashable>(of model: Model, when: @escaping (Int) -> Bool, callback: @escaping () -> Void) {
        trigger(of: model.hashValue, when: when, callback: callback)
    }
    
    /// 更新指定模型的计数，并触发相关的触发器。
    /// - Parameters:
    ///   - model: 要更新的模型，必须遵循 Hashable 协议。
    ///   - count: 增加的计数值，默认为 1。
    /// - Returns: 更新后的计数值。
    @discardableResult
    func update<Model: Hashable>(by model: Model, count: Int = 1) -> Int {
        return update(by: model.hashValue, count: count)
    }
    
    /// 重置指定模型的计数为 0。
    /// - Parameter model: 要重置的模型，必须遵循 Hashable 协议。
    func reset<Model: Hashable>(by model: Model) {
        reset(by: model.hashValue)
    }
    
}
#endif
