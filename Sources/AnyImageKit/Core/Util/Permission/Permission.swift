//
//  Permission.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
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
            return BundleHelper.coreLocalizedString(key: "Photos")
        case .camera:
            return BundleHelper.coreLocalizedString(key: "Camera")
        case .microphone:
            return BundleHelper.coreLocalizedString(key: "Microphone")
        }
    }
    
    var localizedAlertTitle: String {
        return String(format: BundleHelper.coreLocalizedString(key: "%@ is disabled"), localizedTitle)
    }
    
    var localizedAlertMessage: String {
        switch self {
        case .photos:
            return BundleHelper.coreLocalizedString(key: "Allow %@ to access your album in \"Settings -> Privacy -> Photos\"")
        case .camera:
            return BundleHelper.coreLocalizedString(key: "Allow %@ to access your camera in \"Settings -> Privacy -> Camera\"")
        case .microphone:
            return BundleHelper.coreLocalizedString(key: "Allow %@ to access your microphone in \"Settings -> Privacy -> Microphone\"")
        }
    }
}

extension Permission {
    
    enum Status: Equatable {
        
        case notDetermined
        case denied
        case authorized
    }
}
