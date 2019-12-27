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
    func imageCapture(_ capture: ImageCaptureController, didFinishCapturing media: URL, type: CaptureMediaType)
}

extension ImageCaptureControllerDelegate {
    
    public func imageCaptureDidCancel(_ capture: ImageCaptureController) {
        capture.dismiss(animated: true, completion: nil)
    }
}

open class ImageCaptureController: AINavigationController {
    
    open private(set) weak var captureDelegate: ImageCaptureControllerDelegate?
    
    public let config: Config
    
    required public init(config: Config = .init(), delegate: ImageCaptureControllerDelegate) {
        enableDebugLog = config.enableDebugLog
        self.config = config
        super.init(nibName: nil, bundle: nil)
        self.captureDelegate = delegate
        
        let rootViewController = CaptureViewController(config: config)
        rootViewController.delegate = self
        self.viewControllers = [rootViewController]
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        if let _ = presentedViewController as? ImageEditorController {
            presentingViewController?.dismiss(animated: flag, completion: completion)
        } else {
            super.dismiss(animated: flag, completion: completion)
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}
 
// MARK: - CaptureViewControllerDelegate
extension ImageCaptureController: CaptureViewControllerDelegate {
    
    func captureDidCancel(_ capture: CaptureViewController) {
        captureDelegate?.imageCaptureDidCancel(self)
    }
    
    func capture(_ capture: CaptureViewController, didOutput media: URL, type: CaptureMediaType) {
        captureDelegate?.imageCapture(self, didFinishCapturing: media, type: type)
    }
}
