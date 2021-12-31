//
//  Permission+Microphone.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2021 AnyImageKit.org. All rights reserved.
//

import AVFoundation

extension Permission {
    
    func _checkMicrophone() -> Status {
        return AVCaptureDevice.authorizationStatus(for: .audio)._status
    }
    
    @MainActor
    func _requestMicrophone() async -> Permission.Status {
        guard Bundle.main.object(forInfoDictionaryKey: ._microphoneUsageDescription) != nil else {
            _print("WARNING: \(String._microphoneUsageDescription) not found in Info.plist")
            return .denied
        }
        
        let result = await AVCaptureDevice.requestAccess(for: .audio)
        return result ? .authorized : .denied
    }
}

fileprivate extension String {
    
    static let _microphoneUsageDescription: String = "NSMicrophoneUsageDescription"
}
