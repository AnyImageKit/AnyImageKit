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
    
    @MainActor
    func _requestCamera() async -> Permission.Status {
        guard Bundle.main.object(forInfoDictionaryKey: ._cameraUsageDescription) != nil else {
            _print("WARNING: \(String._cameraUsageDescription) not found in Info.plist")
            return .denied
        }
        
        let result = await AVCaptureDevice.requestAccess(for: .video)
        return result ? .authorized : .denied
    }
}

extension AVAuthorizationStatus {
    
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
