//
//  File.swift
//  
//
//  Created by linhey on 2024/3/13.
//

import Foundation

public enum SKHandleResult<Success> {
    case handle(Success)
    case next
}

public extension SKHandleResult {

    static func handleable(_ value: Success?) -> SKHandleResult {
        if let value {
            return .handle(value)
        } else {
            return .next
        }
    }

    func get() -> Success? {
        switch self {
        case .handle(let success):
            return success
        case .next:
            return nil
        }
    }
    
}

public extension SKHandleResult where Success == Void {
    
    static let handle = SKHandleResult.handle(())
    
}

public extension SKHandleResult where Success == Bool {
    
    static let handle = SKHandleResult.handle((true))
    
}
