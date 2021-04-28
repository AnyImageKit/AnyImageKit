//
//  AssetCollection.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/12.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public protocol AssetCollection: Collection, IdentifiableResource {
    /// Localized title
    var localizedTitle: String { get }
    /// Addition elements in asset collection
    var additionOption: AssetCollectionAdditionOption { get }
}
