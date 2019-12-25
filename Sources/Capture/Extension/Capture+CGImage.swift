//
//  Capture+CGImage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/18.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import CoreGraphics
import ImageIO
import MobileCoreServices

extension CGImage {
    
    func jpegData(with matedata: [String: Any] = [:]) -> Data? {
        return data(for: kUTTypeJPEG, with: matedata)
    }
    
    func pngData(with matedata: [String: Any] = [:]) -> Data? {
        return data(for: kUTTypeJPEG, with: matedata)
    }
    
    private func data(for utType: CFString, with matedata: [String: Any]) -> Data? {
        guard
            let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, utType, 1, nil)
            else {
                return nil
        }
        CGImageDestinationAddImage(destination, self, matedata as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}
