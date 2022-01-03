//
//  Permission+Photos.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Photos

extension Permission {
    
    func _checkPhotos() -> Status {
        if #available(iOS 14.0, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite)._status
        } else {
            return PHPhotoLibrary.authorizationStatus()._status
        }
    }
    
    @MainActor
    func _requestPhotos() async -> Permission.Status {
        guard Bundle.main.object(forInfoDictionaryKey: ._photoLibraryUsageDescription) != nil else {
            _print("WARNING: \(String._photoLibraryUsageDescription) not found in Info.plist")
            return .denied
        }
        
        if #available(iOS 14.0, *) {
            return await PHPhotoLibrary.requestAuthorization(for: .readWrite)._status
        } else {
            return await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization { status in
                    continuation.resume(returning: status._status)
                }
            }
        }
    }
}

fileprivate extension PHAuthorizationStatus {
    
    var _status: Permission.Status {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .authorized:
            return .authorized
        case .limited:
            return .limited
        default:
            return .denied
        }
    }
}

fileprivate extension String {
    
    static let _photoLibraryUsageDescription: String = "NSPhotoLibraryUsageDescription"
}
