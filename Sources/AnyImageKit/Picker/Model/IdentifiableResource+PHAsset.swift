//
//  IdentifiableResource+PHAsset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/6/30.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Photos

extension PHAsset: IdentifiableResource {
    
    public var identifier: String {
        return localIdentifier
    }
}
