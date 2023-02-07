//
//  File.swift
//  
//
//  Created by linhey on 2022/8/16.
//

import Foundation

public class SKCRegistrationSectionInjection: SKCSectionInjection {
    
    /// 被删除的数据, 缓存为了在 enddisplay 时正确的被响应
    var supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol] = [:]
    var registrations: [Int: any SKCCellRegistrationProtocol] = [:]
    
    func supplementary(_ kind: SKSupplementaryKind) -> (any SKCSupplementaryRegistrationProtocol)? {
        let item = supplementaries[kind]
        supplementaries[kind] = nil
        return item
    }
    
    func registration(at row: Int) -> (any SKCCellRegistrationProtocol)? {
        let item = registrations[row]
        registrations[row] = nil
        return item
    }
    
}
