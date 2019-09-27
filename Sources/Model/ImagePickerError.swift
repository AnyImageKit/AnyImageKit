//
//  ImagePickerError.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import Foundation

public enum ImagePickerError: Error {
    
    case invalidInfo
    case invalidData
    case invalidDataUTI
    case invalidImage
    case other(Error)
}
