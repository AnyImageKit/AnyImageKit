//
//  EditorToolStyle.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2023/2/22.
//  Copyright © 2023 AnyImageKit.org. All rights reserved.
//

import Foundation

/// The layout style for the toolbar buttons, available only in compact mode of iPad or iPhone.
public enum EditorToolStyle {
    
    /// The Cancel button is at the top left corner, and the Done button is at the bottom right corner.
    case `default`
    
    /// The Cancel button is at the bottom left corner, and the Done button is at the bottom right corner.
    /// Like system Photos App
    case system
}
