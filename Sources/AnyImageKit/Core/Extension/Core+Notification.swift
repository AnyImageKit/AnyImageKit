//
//  Core+Notification.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/11/20.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let containerSizeDidChange = Notification.Name("org.AnyImageProject.AnyImageKit.Notification.Name.ContainerSizeDidChange")
    static let didSyncAsset = Notification.Name("org.AnyImageProject.AnyImageKit.Notification.Name.DidSyncAsset")
}

let containerSizeKey: String = "org.AnyImageProject.AnyImageKit.Notification.Key.ContainerSize"
