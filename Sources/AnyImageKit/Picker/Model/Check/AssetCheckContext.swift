//
//  AssetCheckContext.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/16.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public struct AssetCheckContext<Resource: IdentifiableResource> {
    
    public let selectedAssets: [Asset<Resource>]
}
