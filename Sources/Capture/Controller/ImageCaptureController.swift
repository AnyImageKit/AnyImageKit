//
//  ImageCaptureController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/3.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import SnapKit

public protocol ImageCaptureControllerDelegate: class {
    
    func imageCaptureDidCancel(_ capture: ImageCaptureController)
}

extension ImageCaptureControllerDelegate {
    
    func imageCaptureDidCancel(_ capture: ImageCaptureController) {
        capture.dismiss(animated: true, completion: nil)
    }
}

open class ImageCaptureController: AINavigationController {
    
    open private(set) weak var captureDelegate: ImageCaptureControllerDelegate?
    
    required public init(config: Config = .init(), delegate: ImageCaptureControllerDelegate) {
        enableDebugLog = config.enableDebugLog
        super.init(nibName: nil, bundle: nil)
        
        
        
        let rootViewController = CaptureViewController()
        rootViewController.delegate = self
        self.viewControllers = [rootViewController]
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension ImageCaptureController: CaptureViewControllerDelegate {
    
    
}
