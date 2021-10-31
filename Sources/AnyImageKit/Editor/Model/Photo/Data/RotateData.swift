//
//  RotateData.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/3/18.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

enum RotateDirection: Int, Codable, Equatable {
    
    case left = 0
    case right
}

enum RotateState: Int, Codable, Equatable {
    
    case portrait = 0
    case upsideDown
    case landscapeLeft
    case landscapeRight
    
    var angle: CGFloat {
        let pi = CGFloat.pi
        switch self {
        case .portrait:
            return 0.0
        case .upsideDown:
            return -pi
        case .landscapeLeft:
            return -(pi / 2.0)
        case .landscapeRight:
            return pi / 2.0
        }
    }
    
    var isPortrait: Bool {
        switch self {
        case .portrait, .upsideDown:
            return true
        case .landscapeLeft, .landscapeRight:
            return false
        }
    }
    
    static func getList(by direction: RotateDirection) -> [RotateState] {
        switch direction {
        case .left:
            return [.portrait, .landscapeLeft, .upsideDown, .landscapeRight]
        case .right:
            return [.portrait, .landscapeRight, .upsideDown, .landscapeLeft]
        }
    }
    
    static func nextState(of current: RotateState, direction: RotateDirection) -> RotateState {
        let list = getList(by: direction)
        if let idx = list.firstIndex(of: current) {
            let next = (idx < list.count - 1) ? idx + 1 : 0
            return list[next]
        }
        return .portrait
    }
    
    static func getCropCornerPosition(by rotate: RotateState, position: CropCornerPosition) -> CropCornerPosition {
        var position = position
        switch rotate {
        case .portrait:
            break
        case .upsideDown:
            switch position {
            case .topLeft:
                position = .bottomRight
            case .topRight:
                position = .bottomLeft
            case .bottomLeft:
                position = .topRight
            case .bottomRight:
                position = .topLeft
            }
        case .landscapeLeft:
            switch position {
            case .topLeft:
                position = .topRight
            case .topRight:
                position = .bottomRight
            case .bottomLeft:
                position = .topLeft
            case .bottomRight:
                position = .bottomLeft
            }
        case .landscapeRight:
            switch position {
            case .topLeft:
                position = .bottomLeft
            case .topRight:
                position = .topLeft
            case .bottomLeft:
                position = .bottomRight
            case .bottomRight:
                position = .topRight
            }
        }
        return position
    }
}
