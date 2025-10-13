//
//  Met.swift
//  DesignKit
//
//  Created by linhey on 7/31/25.
//

import Foundation

public final class SKPerformance: Sendable {
    
    public class Record {
        
        public let prefix: String
        public var count: Int
        public var total: TimeInterval
        
        public init(prefix: String, count: Int = 0, total: TimeInterval = 0) {
            self.prefix = prefix
            self.count = count
            self.total = total
        }
        
        func add(time: TimeInterval) {
            total += time
            count += 1
        }
        
    }
    
    public actor AsyncRecord {
        
        public let prefix: String
        public var count: Int
        public var total: TimeInterval
        
        public init(prefix: String, count: Int = 0, total: TimeInterval = 0) {
            self.prefix = prefix
            self.count = count
            self.total = total
        }
        
        func add(time: TimeInterval) {
            total += time
            count += 1
        }
        
    }
    
    public static let shared = SKPerformance()
    private var asyncRecords: [String: AsyncRecord] = [:]
    private var records: [String: Record] = [:]
    
}

public extension SKPerformance {
    
    @discardableResult
    func duration<Value>(
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: Int = #line,
        _ closure: () throws -> Value
    ) rethrows -> Value {
#if DEBUG
        let prefix = "\(file):\(function):\(line)"
        return try duration(unit: 1e-9, prefix, closure)
#else
        return try closure()
#endif
    }
    
    @discardableResult
    func duration<Value>(
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: Int = #line,
        _ closure: @Sendable () async throws -> Value
    ) async rethrows -> Value {
#if DEBUG
        let prefix = "\(file):\(function):\(line)"
        return try await duration(unit: 1e-9, prefix, closure)
#else
        return try await closure()
#endif
    }
    
    /// 耗时(秒)
    /// - Parameter block: 需要测试执行的代码
    @discardableResult
    func duration<Value>(
        unit: Double = 1e-9,
        _ prefix: String,
        _ closure: () throws -> Value
    ) rethrows -> Value {
#if DEBUG
        // 获取转换因子
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        // 获取开始时间
        let t0 = mach_absolute_time()
#endif
        let value = try closure()
#if DEBUG
        // 获取结束时间
        let t1 = mach_absolute_time()
        let time = TimeInterval(Int(t1 - t0) * Int(info.numer) / Int(info.denom)) * unit
        
        // 记录
        if let record = records[prefix] {
            record.add(time: time)
        } else {
            let record = Record(prefix: prefix)
            record.add(time: time)
            records[prefix] = record
        }
        
        debugPrint("[SKPerformance] \(prefix): 耗时 \(time) 秒")
#endif
        return value
    }
    
    /// 耗时(秒)
    /// - Parameter block: 需要测试执行的代码
    @discardableResult
    func duration<Value>(
        unit: Double = 1e-9,
        _ prefix: String,
        _ closure: @Sendable () async throws -> Value
    ) async rethrows -> Value {
#if DEBUG
        // 获取转换因子
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        // 获取开始时间
        let t0 = mach_absolute_time()
#endif
        
        let value = try await closure()
        
#if DEBUG
        // 获取结束时间
        let t1 = mach_absolute_time()
        let time = TimeInterval(Int(t1 - t0) * Int(info.numer) / Int(info.denom)) * unit
        
        // 记录
        if let record = asyncRecords[prefix] {
            await record.add(time: time)
        } else {
            let record = AsyncRecord(prefix: prefix)
            await record.add(time: time)
            asyncRecords[prefix] = record
        }
        debugPrint("[SKPerformance] \(prefix): 耗时 \(time) 秒")
#endif
        return value
    }
    
}

public extension SKPerformance {
    
    struct PrintResult {
        public let key: String
        public let count: Int
        public let total: TimeInterval
        public var average: TimeInterval {
            return count > 0 ? total / Double(count) : 0
        }
    }
    
    func printRecords(sort: (_ lhs: PrintResult, _ rhs: PrintResult) -> Bool = { $0.average > $1.average }) async {
        
        var allResults: [PrintResult] = []
        
        // 同步记录
        for (key, record) in records {
            allResults.append(PrintResult(key: key, count: record.count, total: record.total))
        }
        
        // 异步记录
        for (key, record) in asyncRecords {
            let count = await record.count
            let total = await record.total
            allResults.append(PrintResult(key: key, count: count, total: total))
        }
        
        // 排序（可选）
        allResults.sorted(by: sort)
        let length = allResults.map { $0.key.count }.max() ?? 0
        let padding = max(min(length, 120), 5)
        let paddingStr = String(repeating: "─", count: padding)
        // 打印表格
        debugPrint("┌─\(paddingStr)─┬────────┬────────────┬────────────┐")
        debugPrint("│ Name\(String(repeating: " ", count: padding - 4)) │ Count  │ Total(s)   │ Average(s) │")
        debugPrint("├─\(paddingStr)─┼────────┼────────────┼────────────┤")
        for result in allResults {
            let name = result.key.padding(toLength: padding, withPad: " ", startingAt: 0)
            let countStr = String(format: "%6d", result.count)
            let totalStr = String(format: "%10.4f", result.total)
            let avgStr = String(format: "%10.4f", result.average)
            debugPrint("│ \(name) │ \(countStr) │ \(totalStr) │ \(avgStr) │")
        }
        debugPrint("└─\(paddingStr)─┴────────┴────────────┴────────────┘")
    }
    
}
