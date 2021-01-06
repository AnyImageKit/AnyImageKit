//
//  CaptureResult.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/9/28.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public struct CaptureResult: Equatable {
    
    public let mediaURL: URL
    public let type: MediaType
    
    init(mediaURL: URL, type: MediaType) {
        self.mediaURL = mediaURL
        self.type = type
    }
}
