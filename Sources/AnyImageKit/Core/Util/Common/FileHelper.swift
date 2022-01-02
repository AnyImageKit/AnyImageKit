//
//  FileHelper.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/10/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import MobileCoreServices

struct FileHelper {
    
    static func fileExtension(from dataUTI: CFString) -> String {
        guard
            let declaration = UTTypeCopyDeclaration(dataUTI)?.takeRetainedValue() as? [CFString: Any],
            let tagSpecification = declaration[kUTTypeTagSpecificationKey] as? [CFString: Any] else {
                return "jpg"
        }
        if let fileExtension = tagSpecification[kUTTagClassFilenameExtension] as? String {
            return fileExtension
        }
        return (tagSpecification[kUTTagClassFilenameExtension] as? [String])?.first ?? "jpg"
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
}

extension FileHelper {
    
    @discardableResult
    static func write(photoData: Data, fileType: FileType, filename: String = "") -> URL? {
        write(photoData: photoData, utType: fileType.utType, filename: filename)
    }
    
    @discardableResult
    static func write(photoData: Data, utType: CFString, filename: String = "") -> URL? {
        let url = getTemporaryUrl(by: .photo, utType: utType, filename: filename)
        do {
            try photoData.write(to: url)
            return url
        } catch {
            _print(error.localizedDescription)
        }
        return nil
    }
    
    static func read(fileType: FileType, filename: String) -> Data? {
        return read(utType: fileType.utType, filename: filename)
    }
    
    static func read(utType: CFString, filename: String) -> Data? {
        let url = getTemporaryUrl(by: .photo, utType: utType, filename: filename)
        if !FileManager.default.fileExists(atPath: url.path) { return nil }
        do {
            return try Data(contentsOf: url)
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
    
    static func getTemporaryUrl(by type: MediaType, fileType: FileType, filename: String = "") -> URL {
        return getTemporaryUrl(by: type, utType: fileType.utType, filename: filename)
    }
    
    static func getTemporaryUrl(by type: MediaType, utType: CFString, filename: String = "") -> URL {
        let tmpPath = temporaryDirectory(for: type)
        let name = filename.isEmpty ? dateString() : filename
        let filePath = tmpPath.appending("\(name).\(fileExtension(from: utType))")
        createDirectory(at: tmpPath)
        return URL(fileURLWithPath: filePath)
    }
}
