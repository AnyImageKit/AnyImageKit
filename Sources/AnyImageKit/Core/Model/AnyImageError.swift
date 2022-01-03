//
//  AnyImageError.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public enum AnyImageError: Error {
    
    case invalidMediaType
    case invalidInfo
    case invalidURL
    case invalidData
    case invalidDataUTI
    case invalidImage
    case invalidVideo
    case invalidLivePhoto
    case invalidExportPreset
    case invalidExportSession
    case unsupportedFileType
    case fileWriteFailed
    case exportFailed
    case exportCanceled
    
    case cannotFindInLocal
    
    case savePhotoFailed
    case saveVideoFailed
}
