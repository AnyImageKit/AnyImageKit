//
//  EditorManager.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/24.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class EditorManager {
    
    static let shared: EditorManager = EditorManager()
    
    var image = UIImage()
    var photoConfig = ImageEditorController.PhotoConfig()

    private init() { }
    
}
