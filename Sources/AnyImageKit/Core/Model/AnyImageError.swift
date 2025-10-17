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

extension AnyImageError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidMediaType:
            return BundleHelper.localizedString(key: "ERROR_INVALID_MEDIA_TYPE", module: .core)
        case .invalidInfo:
            return BundleHelper.localizedString(key: "ERROR_INVALID_INFO", module: .core)
        case .invalidURL:
            return BundleHelper.localizedString(key: "ERROR_INVALID_URL", module: .core)
        case .invalidData:
            return BundleHelper.localizedString(key: "ERROR_INVALID_DATA", module: .core)
        case .invalidDataUTI:
            return BundleHelper.localizedString(key: "ERROR_INVALID_DATA_UTI", module: .core)
        case .invalidImage:
            return BundleHelper.localizedString(key: "ERROR_INVALID_IMAGE", module: .core)
        case .invalidVideo:
            return BundleHelper.localizedString(key: "ERROR_INVALID_VIDEO", module: .core)
        case .invalidLivePhoto:
            return BundleHelper.localizedString(key: "ERROR_INVALID_LIVE_PHOTO", module: .core)
        case .invalidExportPreset:
            return BundleHelper.localizedString(key: "ERROR_INVALID_EXPORT_PRESET", module: .core)
        case .invalidExportSession:
            return BundleHelper.localizedString(key: "ERROR_INVALID_EXPORT_SESSION", module: .core)
        case .unsupportedFileType:
            return BundleHelper.localizedString(key: "ERROR_UNSUPPORTED_FILE_TYPE", module: .core)
        case .fileWriteFailed:
            return BundleHelper.localizedString(key: "ERROR_FILE_WRITE_FAILED", module: .core)
        case .exportFailed:
            return BundleHelper.localizedString(key: "ERROR_EXPORT_FAILED", module: .core)
        case .exportCanceled:
            return BundleHelper.localizedString(key: "ERROR_EXPORT_CANCELED", module: .core)
        case .cannotFindInLocal:
            return BundleHelper.localizedString(key: "ERROR_CANNOT_FIND_IN_LOCAL", module: .core)
        case .savePhotoFailed:
            return BundleHelper.localizedString(key: "ERROR_SAVE_PHOTO_FAILED", module: .core)
        case .saveVideoFailed:
            return BundleHelper.localizedString(key: "ERROR_SAVE_VIDEO_FAILED", module: .core)
        }
    }
}
