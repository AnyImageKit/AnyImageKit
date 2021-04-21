//
//  EditorVideoToolOption.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

/// Video tool option
public enum EditorVideoToolOption: Equatable, CaseIterable {
    
    case clip
}

extension EditorVideoToolOption {
    
    var imageName: String {
        switch self {
        case .clip:
            return "VideoToolVideo"
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
}
