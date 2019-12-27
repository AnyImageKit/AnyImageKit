//
//  FileType.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation
import MobileCoreServices

enum FileType: Equatable {
    
    case jpeg
    case png
    
    var fileExtension: String {
        switch self {
        case .jpeg:
            return ".jpeg"
        case .png:
            return ".png"
        }
    }
    
    var utType: CFString {
        switch self {
        case .jpeg:
            return kUTTypeJPEG
        case .png:
            return kUTTypePNG
        }
    }
}
