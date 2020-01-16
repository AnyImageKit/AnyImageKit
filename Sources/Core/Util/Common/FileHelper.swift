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
    
    static func write(photoData: Data, utType: CFString) -> URL? {
        let tmpPath = temporaryDirectory(for: .photo)
        let dateString = FileHelper.dateString()
        let filePath = tmpPath.appending("Photo-\(dateString).\(FileHelper.fileExtension(from: utType))")
        FileHelper.createDirectory(at: tmpPath)
        let url = URL(fileURLWithPath: filePath)
        // Write to file
        do {
            try photoData.write(to: url)
            print("Did write file at \(url)")
            return url
        } catch {
            _print(error.localizedDescription)
        }
        return nil
    }
}

extension FileHelper {
    
    static func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss-SSS"
        return formatter.string(from: Date())
    }
    
    static func temporaryDirectory(for type: MediaType) -> String {
        let systemTemp = NSTemporaryDirectory()
        if type.isImage {
            return systemTemp.appending("AnyImageKit/Photo/")
        } else {
            return systemTemp.appending("AnyImageKit/Video/")
        }
    }
}
