//
//  UserInterfaceStyle.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/11/12.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

/// User Interface Style 主题风格
public enum UserInterfaceStyle: Equatable {
    /// Auto model 自动模式
    /// - iOS 13+ depend on system, below iOS 13 equal to Light mode
    /// - iOS 13+ 会根据系统样式自动更改，低于 iOS 13 为 Light mode
    case auto
    /// Light mode 浅色模式
    case light
    /// Dark mode 深色模式
    case dark
}
