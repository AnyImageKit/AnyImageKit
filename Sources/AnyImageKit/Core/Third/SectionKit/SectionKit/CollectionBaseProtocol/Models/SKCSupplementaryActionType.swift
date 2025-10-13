//
//  File.swift
//  
//
//  Created by linhey on 2024/3/15.
//

import Foundation

public enum SKCSupplementaryActionType: Int, Hashable {
    case reload
    /// 即将显示
    case willDisplay
    /// 结束显示
    case didEndDisplay
}
