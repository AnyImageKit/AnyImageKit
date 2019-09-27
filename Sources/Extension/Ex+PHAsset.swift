//
//  Ex+PHAsset.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Photos
import MobileCoreServices

extension PHAsset {
    
    var isGIF: Bool {
        guard let resource = PHAssetResource.assetResources(for: self).first else {
            if let fileName = value(forKey: "filename") as? String {
                return fileName.hasSuffix("GIF")
            } else {
                return false
            }
        }
        let uti = resource.uniformTypeIdentifier
        return UTTypeConformsTo(uti as CFString, kUTTypeGIF)
    }
}
