//
//  SKCCellActionType.swift
//  SectionKit
//
//  Created by linhey on 5/22/25.
//

import Foundation

public enum SKCCellActionType: Int, Hashable {
    /// 选中
    case selected
    case deselected
    /// 即将显示
    case willDisplay
    /// 结束显示
    case didEndDisplay
    /// 配置完成
    case config
    
    public var description: String {
        switch self {
        case .selected: return "selected"
        case .deselected: return "deselected"
        case .willDisplay: return "willDisplay"
        case .didEndDisplay: return "didEndDisplay"
        case .config: return "config"
        }
    }
}
