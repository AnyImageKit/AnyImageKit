//
//  EditorOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/9/22.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

/// 画笔颜色样式
public enum EditorPenColorOption: Equatable {
    /// 自定义颜色
    case custom(color: UIColor)
    
    #if swift(>=5.5)
    /// Fix Xcode 13 beta bug.
    case colorWell(color: UIColor)
    #else
    /// UIColorWell
    @available(iOS 14.0, *)
    case colorWell(color: UIColor)
    #endif
}

/// 马赛克样式
public enum EditorMosaicOption: Equatable {
    /// 默认马赛克
    case `default`
    /// 自定义马赛克
    case custom(icon: UIImage?, mosaic: UIImage)
    
    public static var colorful: EditorMosaicOption {
        return .custom(icon: nil, mosaic: BundleHelper.image(named: "CustomMosaic", module: .editor)!)
    }
}

/// 输入文本颜色
public struct EditorTextColor: Equatable {
    /// 主色
    public let color: UIColor
    /// 辅色
    public let subColor: UIColor
}

/// 裁剪比例
public enum EditorCropOption: Equatable {
    /// 自由裁剪
    case free
    /// 自定义裁剪 宽高比
    case custom(w: UInt, h: UInt)
}

// MARK: - CaseIterable
extension EditorPenColorOption: CaseIterable {
    
    public static var allCases: [EditorPenColorOption] {
        var cases: [EditorPenColorOption] = Palette.penColors.map { .custom(color: $0) }
        if #available(iOS 14.0, *) {
            cases[cases.count-1] = .colorWell(color: Palette.penColors.last!)
            return cases
        } else {
            return cases
        }
    }
}

extension EditorMosaicOption: CaseIterable {
    
    public static var allCases: [EditorMosaicOption] {
        return [.default, .colorful]
    }
}

extension EditorCropOption: CaseIterable {
    
    public static var allCases: [EditorCropOption] {
        return [.free, .custom(w: 1, h: 1), .custom(w: 3, h: 4), .custom(w: 4, h: 3), .custom(w: 9, h: 16), .custom(w: 16, h: 9)]
    }
}

// MARK: - Extension
extension EditorPenColorOption {
    
    var color: UIColor {
        switch self {
        case .custom(let color):
            return color
        case .colorWell(let color):
            return color
        }
    }
}

extension EditorCropOption {
    
    var ratioOfWidth: CGFloat {
        switch self {
        case .free:
            return 1
        case .custom(let w, let h):
            return CGFloat(w)/CGFloat(h)
        }
    }
    
    var ratioOfHeight: CGFloat {
        switch self {
        case .free:
            return 1
        case .custom(let w, let h):
            return CGFloat(h)/CGFloat(w)
        }
    }
}
