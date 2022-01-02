//
//  EditorVideoToolOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

/// Video tool option
public enum EditorVideoToolOption: Equatable, CaseIterable {
    
    case clip
}

extension EditorVideoToolOption {
    
    var iconKey: EditorTheme.IconConfigKey {
        switch self {
        case .clip:
            return .videoToolVideo
        }
    }
}

extension EditorVideoToolOption: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .clip:
            return "CROP"
        }
    }
    
    var stringKey: StringConfigKey {
        switch self {
        case .clip:
            return .editorCrop
        }
    }
}
