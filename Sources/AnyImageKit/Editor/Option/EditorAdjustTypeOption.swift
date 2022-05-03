//
//  EditorAdjustTypeOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2022/2/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public enum EditorAdjustTypeOption: Equatable, CaseIterable {
    
    case exposure
    case brilliance
    case highlights
    case shadows
    case contrast
    case brightness
    case blackPoint
    case saturation
    case vibrance
    case warmth
    case tint
    case sharpness
    case definition
    case noiseReduction
    case vignette
}

extension EditorAdjustTypeOption {
    
    var iconKey: EditorTheme.IconConfigKey {
        switch self {
        case .exposure:
            return .adjustExposure
        case .brilliance:
            return .adjustBrilliance
        case .highlights:
            return .adjustHighlights
        case .shadows:
            return .adjustShadows
        case .contrast:
            return .adjustContrast
        case .brightness:
            return .adjustBrightness
        case .blackPoint:
            return .adjustBlackPoint
        case .saturation:
            return .adjustSaturation
        case .vibrance:
            return .adjustVibrance
        case .warmth:
            return .adjustWarmth
        case .tint:
            return .adjustTint
        case .sharpness:
            return .adjustSharpness
        case .definition:
            return .adjustDefinition
        case .noiseReduction:
            return .adjustNoiseReduction
        case .vignette:
            return .adjustVignette
        }
    }
}

extension EditorAdjustTypeOption {
    
    var stringKey: StringConfigKey {
        switch self {
        case .exposure:
            return .editorExposure
        case .brilliance:
            return .editorBrilliance
        case .highlights:
            return .editorHighlights
        case .shadows:
            return .editorShadows
        case .contrast:
            return .editorContrast
        case .brightness:
            return .editorBrightness
        case .blackPoint:
            return .editorBlackPoint
        case .saturation:
            return .editorSaturation
        case .vibrance:
            return .editorVibrance
        case .warmth:
            return .editorWarmth
        case .tint:
            return .editorTint
        case .sharpness:
            return .editorSharpness
        case .definition:
            return .editorDefinition
        case .noiseReduction:
            return .editorNoiseReduction
        case .vignette:
            return .editorVignette
        }
    }
}
