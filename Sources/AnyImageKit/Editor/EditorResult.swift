//
//  EditorResult.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/9/28.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public struct EditorResult: Equatable {
    
    /// Local media url. Store in temporary directory.
    /// If you want to keep this file, you should move it to your document directory.
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
