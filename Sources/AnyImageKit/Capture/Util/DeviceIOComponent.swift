//
//  DeviceIOComponent.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/13.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import AVFoundation

class DeviceIOComponent: NSObject {
    
    var device: AVCaptureDevice?
    var input: AVCaptureDeviceInput?
}

// MARK: - Device Property
extension DeviceIOComponent {
    
    func updateProperty(_ change: (AVCaptureDevice) -> Void) {
        guard let device = device else { return }
        do {
            try device.lockForConfiguration()
            change(device)
            device.unlockForConfiguration()
        } catch {
            _print(error.localizedDescription)
        }
    }
}
