//
//  File.swift
//  
//
//  Created by linhey on 2023/7/20.
//

import Foundation

public struct SKModelDisplayedAt: ExpressibleByIntegerLiteral, ExpressibleByArrayLiteral {
    
    public static let first: SKModelDisplayedAt = 1
    
    public let predicate: (_ count: Int) -> Bool
    
    public init(arrayLiteral elements: Int...) {
        self.init { count in
            elements.contains(count)
        }
    }
    
    public init(integerLiteral value: Int) {
        self.init { count in
            count == value
        }
    }

    public init(_ predicate: @escaping (_ count: Int) -> Bool) {
        self.predicate = predicate
    }
    
}

public extension SKCSingleTypeSection {
    
    struct ModelDisplayedContext {
        public let section: SKCSingleTypeSection<Cell>
        public let model: Model
        public let row: Int
    }
    
    /// 监听 model 显示次数
    /// - Parameters:
    ///  - time: 显示次数
    ///  - observe: 监听回调
    ///  - context: 上下文
    @discardableResult
    func model(displayedAt time: SKModelDisplayedAt,
               observe: @escaping (_ context: ModelDisplayedContext) -> Void) -> Self {
        displayedTimes.trigger { [weak self] (row, count) in
            guard let self = self,
                  time.predicate(count),
                  self.models.indices.contains(row) else {
                return
            }
            observe(.init(section: self, model: models[row], row: row))
        }
        return self
    }
    
}
