//
//  FileHelper.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/10/16.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
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
    
    static func createDirectory(at path: String) {
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
    
    static func write(photoData: Data, fileType: FileType) -> URL? {
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        let tmpPath = NSTemporaryDirectory()
        let filePath = tmpPath.appending("PHOTO-SAVED-\(timestamp)"+fileType.fileExtension)
        FileHelper.createDirectory(at: tmpPath)
        let url = URL(fileURLWithPath: filePath)
        // Write to file
        do {
            try photoData.write(to: url)
            return url
        } catch {
            _print(error.localizedDescription)
        }
        return nil
    }
}
