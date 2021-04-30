//
//  PickerResult.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/9/28.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Photos

public struct PickerResult: Equatable {
    
    public let assets: [Asset<PHAsset>]
    public let useOriginalImage: Bool
    
    init(assets: [Asset<PHAsset>], useOriginalImage: Bool) {
        self.assets = assets
        self.useOriginalImage = useOriginalImage
    }
}
