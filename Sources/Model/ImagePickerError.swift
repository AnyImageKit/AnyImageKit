//
//  ImagePickerError.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Foundation

public enum ImagePickerError: Error {
    
    case invalidMediaType
    case invalidInfo
    case invalidData
    case invalidDataUTI
    case invalidImage
    case invalidVideo
    case invalidExportPreset
    case invalidExportSession
    case unsupportedFileType
    case directoryCreateFail
    case fileWriteFail
    case exportFail
    case exportCancel
}
