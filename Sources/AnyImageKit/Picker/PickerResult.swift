//
//  PickerResult.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/9/28.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import Photos

public struct PickerResult: Equatable {
    
    public let assets: [Asset<PHAsset>]
    public let useOriginalImage: Bool
    
    init(assets: [Asset<PHAsset>], useOriginalImage: Bool) {
        self.assets = assets
        self.useOriginalImage = useOriginalImage
    }
}
