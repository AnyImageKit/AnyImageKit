//
//  EditorTextColor.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/4/16.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import UIKit

/// Text color
///
/// There are two display styles for each text color element.
/// One is no background color, the text color is main color.
/// The other is that the background color is main color, and the text color is sub color(usually is white).
public struct EditorTextColor: Equatable, Hashable {
    
    /// Main color
    public let color: UIColor
    
    /// Sub color
    public let subColor: UIColor
}
