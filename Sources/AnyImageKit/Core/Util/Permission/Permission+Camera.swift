//
//  Permission+Camera.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import AVFoundation

extension Permission {
    
    func _checkCamera() -> Status {
        return AVCaptureDevice.authorizationStatus(for: .video)._status
    }
    
    func _requestCamera(completion: @escaping PermissionCompletion) {
        guard Bundle.main.object(forInfoDictionaryKey: ._cameraUsageDescription) != nil else {
            _print("WARNING: \(String._cameraUsageDescription) not found in Info.plist")
            return
        }
        
        AVCaptureDevice.requestAccess(for: .video) { result in
            Thread.runOnMain {
                if result {
                    completion(.authorized)
                } else {
                    completion(.denied)
                }
            }
        }
    }
}

fileprivate extension AVAuthorizationStatus {
    
    var _status: Permission.Status {
        switch self {
        case .authorized:
            return .authorized
        case .notDetermined:
            return .notDetermined
        default:
            return .denied
        }
    }
}

fileprivate extension String {
    
    static let _cameraUsageDescription: String = "NSCameraUsageDescription"
}
