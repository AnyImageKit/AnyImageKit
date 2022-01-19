//
//  PickerResult.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/9/28.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public struct PickerResult: Equatable {
    
    public let assets: [AssetOld]
    public let useOriginalImage: Bool
    
    init(assets: [AssetOld], useOriginalImage: Bool) {
        self.assets = assets
        self.useOriginalImage = useOriginalImage
    }
}
