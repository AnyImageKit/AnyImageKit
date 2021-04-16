//
//  AssetCollection.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public protocol AssetCollection: IdentifiableResource {
    /// Localized title
    var localizedTitle: String { get }
    /// Elements in asset collection
    var elements: [Asset] { get }
    /// Extra elements in asset collection
    var extraElements: AssetCollectionExtraElements { get }
}

public struct AssetCollectionExtraElements: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
}

#if ANYIMAGEKIT_ENABLE_CAPTURE
extension AssetCollectionExtraElements {
    
    public static let camera: AssetCollectionExtraElements = .init(1 << 1)
}
#endif
