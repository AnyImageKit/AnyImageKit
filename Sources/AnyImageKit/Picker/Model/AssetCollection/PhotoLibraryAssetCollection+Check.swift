//
//  PhotoLibraryAssetCollection+Check.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/21.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import Photos

extension PhotoLibraryAssetCollection {
    
    var selectItems: [PhotoAsset] {
        checker.selectedItems
    }
}

extension PhotoLibraryAssetCollection {
    
    func reset(preselected identifiers: [String], disableCheckRules: [AssetDisableCheckRule<PHAsset>]) {
        checker.reset(preselected: identifiers, disableCheckRules: disableCheckRules)
    }
}
