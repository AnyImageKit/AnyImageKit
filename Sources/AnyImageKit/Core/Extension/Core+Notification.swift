//
//  Core+Notification.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/11/20.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let containerSizeDidChange = Notification.Name("org.AnyImageKit.Notification.Name.ContainerSizeDidChange")
    static let didSyncAsset = Notification.Name("org.AnyImageKit.Notification.Name.DidSyncAsset")
}

let containerSizeKey: String = "org.AnyImageKit.Notification.Key.ContainerSize"
