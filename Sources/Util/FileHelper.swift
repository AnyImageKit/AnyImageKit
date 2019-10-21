//
//  FileHelper.swift
//  AnyImagePicker
//
//  Created by 刘栋 on 2019/10/16.
//  Copyright © 2019 anotheren.com. All rights reserved.
//

import MobileCoreServices

struct FileHelper {
    
    static func fileExtension(from dataUTI: CFString) -> String {
        guard
            let declaration = UTTypeCopyDeclaration(dataUTI)?.takeRetainedValue() as? [CFString: Any],
            let tagSpecification = declaration[kUTTypeTagSpecificationKey] as? [CFString: Any],
            let fileExtension = tagSpecification[kUTTagClassFilenameExtension] as? String else {
                return ""
        }
        return fileExtension
    }
    
    static func checkDirectory(path: String) {
        var isDirectory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                _print(error.localizedDescription)
            }
        }
    }
}
