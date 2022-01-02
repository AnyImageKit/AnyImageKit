//
//  Permission.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

typealias PermissionCompletion = (Permission.Status) -> Void

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
    
    func request(completion: @escaping PermissionCompletion) {
        switch self {
        case .photos:
            _requestPhotos(completion: completion)
        case .camera:
            _requestCamera(completion: completion)
        case .microphone:
            _requestMicrophone(completion: completion)
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
    }
}
