//
//  AssetCollectionAdditionOption.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/23.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public struct AssetCollectionAdditionOption: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
}

#if ANYIMAGEKIT_ENABLE_CAPTURE
extension AssetCollectionAdditionOption {
    
    public static let camera: AssetCollectionAdditionOption = .init(1 << 0)
}
#endif
