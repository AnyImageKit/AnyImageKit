//
//  AdjustParameter.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import UIKit

struct AdjustRange {
    
    let defaultValue: CGFloat
    let maxValue: CGFloat
    let minValue: CGFloat
    
    func value(of present: CGFloat) -> CGFloat {
        return (maxValue - minValue) * present + minValue
    }
    
    /// return 0 ~ 1
    func present(of value: CGFloat) -> CGFloat {
        return (value - minValue) / (maxValue - minValue)
    }
    
    /// return -1 ~ 1
    func circlePresent(of value: CGFloat) -> CGFloat {
        let result: CGFloat
        if value > defaultValue {
            result = (value - defaultValue) / (maxValue - defaultValue)
        } else if value < defaultValue {
            result = -((value - defaultValue) / (minValue - defaultValue))
        } else {
            result = 0.0
        }
        
        if -0.01 < result && result < 0.01 {
            return 0.0
        } else {
            return result
        }
    }
}

struct AdjustParameter {
    
    let option: EditorAdjustTypeOption
    
    init(option: EditorAdjustTypeOption) {
        self.option = option
    }
}

extension AdjustParameter {
    
    var filterName: String {
        switch option {
        case .exposure: return "CIExposureAdjust"
        case .brilliance: return "CISharpenLuminance"
        case .highlights: return "CIHighlightShadowAdjust"
        case .shadows: return "CIHighlightShadowAdjust"
        case .contrast: return "CIColorControls"
        case .brightness: return "CIColorControls"
        case .blackPoint: return ""
        case .saturation: return "CIColorControls"
        case .vibrance: return "CIVibrance"
        case .warmth: return "CITemperatureAndTint"
        case .tint: return "CITemperatureAndTint"
        case .sharpness: return "CINoiseReduction"
        case .definition: return ""
        case .noiseReduction: return "CINoiseReduction"
        case .vignette: return "CIVignette"
        }
    }
    
    var key: String {
        switch option {
        case .exposure: return "inputEV"
        case .brilliance: return "inputSharpness"
        case .highlights: return "inputHighlightAmount"
        case .shadows: return "inputShadowAmount"
        case .contrast: return "inputContrast"
        case .brightness: return "inputBrightness"
        case .blackPoint: return ""
        case .saturation: return "inputSaturation"
        case .vibrance: return "inputAmount"
        case .warmth: return "inputNeutral"
        case .tint: return "inputNeutral"
        case .sharpness: return "inputSharpness"
        case .definition: return ""
        case .noiseReduction: return "inputNoiseLevel"
        case .vignette: return "inputIntensity"
        }
    }
    
    var range: AdjustRange {
        switch option {
        case .exposure: return .init(defaultValue: 0, maxValue: 2.2, minValue: -2.2)
        case .brilliance: return .init(defaultValue: 0.4, maxValue: 2, minValue: 0)
        case .highlights: return .init(defaultValue: 0.5, maxValue: 1, minValue: 0.3)
        case .shadows: return .init(defaultValue: 0, maxValue: 0.7, minValue: -0.7)
        case .contrast: return .init(defaultValue: 1, maxValue: 4, minValue: 0)
        case .brightness: return .init(defaultValue: 0, maxValue: 1, minValue: -1)
        case .blackPoint: return .init(defaultValue: 0, maxValue: 0, minValue: 0)
        case .saturation: return .init(defaultValue: 1, maxValue: 2, minValue: 0)
        case .vibrance: return .init(defaultValue: 0, maxValue: 1, minValue: -1)
        case .warmth: return .init(defaultValue: 0, maxValue: 0, minValue: 0)
        case .tint: return .init(defaultValue: 0, maxValue: 0, minValue: 0)
        case .sharpness: return .init(defaultValue: 0.4, maxValue: 2, minValue: 0)
        case .definition: return .init(defaultValue: 0, maxValue: 0, minValue: 0)
        case .noiseReduction: return .init(defaultValue: 0.02, maxValue: 0.1, minValue: 0)
        case .vignette: return .init(defaultValue: 0, maxValue: 1, minValue: -1)
        }
    }
}
