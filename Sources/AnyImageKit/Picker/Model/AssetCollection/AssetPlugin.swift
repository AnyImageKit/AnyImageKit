//
//  AssetPlugin.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/23.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public struct AssetPlugin: RawRepresentable, Hashable {

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

#if ANYIMAGEKIT_ENABLE_CAPTURE
extension AssetPlugin {
    
    public static let camera: AssetPlugin = .init(rawValue: "org.AnyImageKit.AssetCollectionAddition.Camera")
}
#endif