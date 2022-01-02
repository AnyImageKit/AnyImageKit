//
//  Capture+CGImage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/18.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import CoreGraphics
import ImageIO

extension CGImage {
    
    func jpegData(compressionQuality: CGFloat) -> Data? {
        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: compressionQuality as CFNumber]
        return data(fileType: .jpeg, options: options)
    }
    
    func pngData() -> Data? {
        return data(fileType: .png)
    }
    
    private func data(fileType: FileType, options: [CFString: Any] = [:]) -> Data? {
        guard
            let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, fileType.utType, 1, nil)
            else {
                return nil
        }
        CGImageDestinationAddImage(destination, self, options as CFDictionary)
        // TODO: add meta
        // CGImageDestinationAddImageAndMetadata
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}
