//
//  Permission.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2021 AnyImageKit.org. All rights reserved.
//

import Foundation

enum Permission: Equatable {
    
    case photos
    case camera
    case microphone
    
    var status: Status {
        switch self {
        case .photos:
            return _checkPhotos()
        case .camera:
            return _checkCamera()
        case .microphone:
            return _checkMicrophone()
        }
    }
    
    @MainActor
    func request() async -> Permission.Status {
        switch self {
        case .photos:
            return await _requestPhotos()
        case .camera:
            return await _requestCamera()
        case .microphone:
            return await _requestMicrophone()
        }
    }
}

extension Permission {
    
    var localizedTitleKey: StringConfigKey {
        switch self {
        case .photos:
            return .photos
        case .camera:
            return .camera
        case .microphone:
            return .microphone
        }
    }
    
    var localizedAlertMessageKey: StringConfigKey {
        switch self {
        case .photos:
            return .noPhotosPermissionTips
        case .camera:
            return .noCameraPermissionTips
        case .microphone:
            return .noMicrophonePermissionTips
        }
    }
}

extension Permission {
    
    enum Status: Equatable {
        
        case notDetermined
        case denied
        case authorized
        case limited // Photos only
        
        var checkedStatus: Permission.CheckedStatus {
            switch self {
            case .authorized:
                return .authorized
            case .denied:
                return .denied
            default:
                return .limited
            }
        }
    }
    
    enum CheckedStatus: Equatable {
        
        case denied
        case authorized
        case limited // Photos only
    }
}
