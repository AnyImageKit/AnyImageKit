//
//  CaptureWhiteBalance.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/14.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import AVFoundation

struct CaptureWhiteBalance: Equatable {
    
    var temperature: Float
    var tint: Float
    
    init(temperature: Float, tint: Float) {
        self.temperature = temperature
        self.tint = tint
    }
    
    init(_ values: AVCaptureDevice.WhiteBalanceTemperatureAndTintValues) {
        self.init(temperature: values.temperature, tint: values.tint)
    }
}
