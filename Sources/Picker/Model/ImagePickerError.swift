//
//  ImagePickerError.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import Foundation

public enum ImagePickerError: Error {
    
    case invalidMediaType
    case invalidInfo
    case invalidData
    case invalidDataUTI
    case invalidImage
    case invalidVideo
    case invalidLivePhoto
    case invalidExportPreset
    case invalidExportSession
    case unsupportedFileType
    case directoryCreateFail
    case fileWriteFail
    case exportFail
    case exportCancel
    
    case cannotFindInLocal
    
    case savePhotoFail
    case saveVideoFail
}
