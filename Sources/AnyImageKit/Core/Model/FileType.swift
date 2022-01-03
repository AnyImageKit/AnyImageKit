//
//  FileType.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import MobileCoreServices

enum FileType: Equatable {
    
    case jpeg
    case png
    case mp4
    
    var fileExtension: String {
        switch self {
        case .jpeg:
            return ".jpeg"
        case .png:
            return ".png"
        case .mp4:
            return ".mp4"
        }
    }
    
    var utType: CFString {
        switch self {
        case .jpeg:
            return kUTTypeJPEG
        case .png:
            return kUTTypePNG
        case .mp4:
            return kUTTypeMPEG4
        }
    }
}
