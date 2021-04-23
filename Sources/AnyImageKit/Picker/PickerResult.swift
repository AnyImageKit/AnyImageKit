//
//  PickerResult.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/9/28.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public struct PickerResult: Equatable {
    
    public let assets: [PhotoAsset]
    public let useOriginalImage: Bool
    
    init(assets: [PhotoAsset], useOriginalImage: Bool) {
        self.assets = assets
        self.useOriginalImage = useOriginalImage
    }
}
