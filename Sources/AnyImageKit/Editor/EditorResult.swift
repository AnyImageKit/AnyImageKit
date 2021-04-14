//
//  EditorResult.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/9/28.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public struct EditorResult: Equatable {
    
    /// Local media url
    public let mediaURL: URL
    
    /// Media type
    public let type: MediaType
    
    /// Media is edited or not
    public let isEdited: Bool
    
    init(mediaURL: URL, type: MediaType, isEdited: Bool) {
        self.mediaURL = mediaURL
        self.type = type
        self.isEdited = isEdited
    }
}
