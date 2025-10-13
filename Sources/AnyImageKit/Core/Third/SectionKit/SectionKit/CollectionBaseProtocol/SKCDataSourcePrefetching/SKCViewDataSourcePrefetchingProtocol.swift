//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

#if canImport(UIKit)
import UIKit

public protocol SKCViewDataSourcePrefetchingProtocol {
    /// 预测加载 rows
    /// - Parameter rows: rows
    func prefetch(at rows: [Int])
    /// 取消加载
    /// - Parameter rows: rows
    func cancelPrefetching(at rows: [Int])
}

#endif