//
//  AssetCollectionAddition.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/23.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public struct AssetCollectionAddition: RawRepresentable, Hashable {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

#if ANYIMAGEKIT_ENABLE_CAPTURE
extension AssetCollectionAddition {
    
    public static let camera: AssetCollectionAddition = .init(rawValue: 1)
}
#endif
