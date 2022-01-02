//
//  Permission+Microphone.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import AVFoundation

extension Permission {
    
    func _checkMicrophone() -> Status {
        return AVAudioSession.sharedInstance().recordPermission._status
    }
    
    func _requestMicrophone(completion: @escaping PermissionCompletion) {
        guard Bundle.main.object(forInfoDictionaryKey: ._microphoneUsageDescription) != nil else {
            _print("WARNING: \(String._microphoneUsageDescription) not found in Info.plist")
            return
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { result in
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

fileprivate extension AVAudioSession.RecordPermission {
    
    var _status: Permission.Status {
        switch self {
        case .denied:
            return .denied
        case .granted:
            return .authorized
        default:
            return .notDetermined
        }
    }
}

fileprivate extension String {
    
    static let _microphoneUsageDescription: String = "NSMicrophoneUsageDescription"
}
