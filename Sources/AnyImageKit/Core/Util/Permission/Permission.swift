//
//  Permission.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
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
    
    var localizedTitle: String {
        switch self {
        case .photos:
            return BundleHelper.coreLocalizedString(key: "PHOTOS")
        case .camera:
            return BundleHelper.coreLocalizedString(key: "CAMERA")
        case .microphone:
            return BundleHelper.coreLocalizedString(key: "MICROPHONE")
        }
    }
    
    var localizedAlertTitle: String {
        return String(format: BundleHelper.coreLocalizedString(key: "PERMISSION_IS_DISABLED"), localizedTitle)
    }
    
    var localizedAlertMessage: String {
        switch self {
        case .photos:
            return BundleHelper.coreLocalizedString(key: "NO_PHOTOS_PERMISSION_TIPS")
        case .camera:
            return BundleHelper.coreLocalizedString(key: "NO_CAMERA_PERMISSION_TIPS")
        case .microphone:
            return BundleHelper.coreLocalizedString(key: "NO_MICROPHONE_PERMISSION_TIPS")
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
