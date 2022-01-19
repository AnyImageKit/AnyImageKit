//
//  IdentifiableResource+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import Photos

extension PHAsset: IdentifiableResource {
    
    public var identifier: String {
        return localIdentifier
    }
}
