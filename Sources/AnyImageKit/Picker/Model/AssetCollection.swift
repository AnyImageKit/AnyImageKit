//
//  AssetCollection.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public protocol AssetCollection: BidirectionalCollection, IdentifiableResource {
    /// Localized title
    var localizedTitle: String { get }
    /// Addition elements before asset collection
    var prefixAdditions: [AssetCollectionAddition] { get }
    /// Addition elements after asset collection
    var suffixAdditions: [AssetCollectionAddition] { get }
}
