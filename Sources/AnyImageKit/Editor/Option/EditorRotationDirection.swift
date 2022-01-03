//
//  EditorRotationDirection.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/3.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public enum EditorRotationDirection: Equatable {
    
    /// Turn off rotation feature
    case turnOff
    
    /// Turn left
    case turnLeft
    
    /// Turn right
    case turnRight
}

extension EditorRotationDirection {
    
    var iconKey: EditorTheme.IconConfigKey {
        switch self {
        case .turnOff:
            return .photoToolCropTrunLeft
        case .turnLeft:
            return .photoToolCropTrunLeft
        case .turnRight:
            return .photoToolCropTrunRight
        }
    }
}
