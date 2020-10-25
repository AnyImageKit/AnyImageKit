//
//  ImageCaptureController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/3.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import UIKit
import SnapKit

public protocol ImageCaptureControllerDelegate: AnyObject {
    
    func imageCaptureDidCancel(_ capture: ImageCaptureController)
    func imageCapture(_ capture: ImageCaptureController, didFinishCapturing result: CaptureResult)
}

extension ImageCaptureControllerDelegate {
    
    public func imageCaptureDidCancel(_ capture: ImageCaptureController) {
        capture.dismiss(animated: true, completion: nil)
    }
}

open class ImageCaptureController: AnyImageNavigationController {
    
    open weak var captureDelegate: ImageCaptureControllerDelegate?
    
    /// Init Capture Controller
    /// - Note: iPadOS will use `UIImagePickerController` instead.
    public required init(options: CaptureOptionsInfo) {
        enableDebugLog = options.enableDebugLog
        super.init(nibName: nil, bundle: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let rootViewController = PadCaptureViewController(options: options)
            rootViewController.delegate = self
            rootViewController.trackObserver = self
            self.viewControllers = [rootViewController]
        } else {
            let rootViewController = CaptureViewController(options: options)
            rootViewController.delegate = self
            rootViewController.trackObserver = self
            self.viewControllers = [rootViewController]
        }
    }
    
    /// Init Capture Controller
    /// - Note: iPadOS will use `UIImagePickerController` instead.
    public convenience init(options: CaptureOptionsInfo, delegate: ImageCaptureControllerDelegate) {
        self.init(options: options)
        self.captureDelegate = delegate
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        var didDismiss = false
        #if ANYIMAGEKIT_ENABLE_EDITOR
        if let _ = presentedViewController as? ImageEditorController {
            didDismiss = true
            presentingViewController?.dismiss(animated: flag, completion: completion)
        }
        #endif
        if !didDismiss {
            if let _ = presentedViewController as? UIImagePickerController {
                presentingViewController?.dismiss(animated: flag, completion: completion)
            } else {
                super.dismiss(animated: flag, completion: completion)
            }
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
    
    func capture(_ capture: CaptureViewController, didOutput mediaURL: URL, type: MediaType) {
        let result = CaptureResult(mediaURL: mediaURL, type: type)
        captureDelegate?.imageCapture(self, didFinishCapturing: result)
    }
}

// MARK: - PadCaptureViewControllerDelegate
extension ImageCaptureController: PadCaptureViewControllerDelegate {
    
    func captureDidCancel(_ capture: PadCaptureViewController) {
        captureDelegate?.imageCaptureDidCancel(self)
    }
    
    func capture(_ capture: PadCaptureViewController, didOutput mediaURL: URL, type: MediaType) {
        let result = CaptureResult(mediaURL: mediaURL, type: type)
        captureDelegate?.imageCapture(self, didFinishCapturing: result)
    }
}
