//
//  ImageCaptureController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/3.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
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
    
    public required init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    /// Init Capture
    /// - Note: iPadOS will use `UIImagePickerController` instead.
    public convenience init(options: CaptureOptionsInfo, delegate: ImageCaptureControllerDelegate) {
        self.init()
        self.update(options: options)
        self.captureDelegate = delegate
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .fullScreen
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
}

extension ImageCaptureController {
    
    open func update(options: CaptureOptionsInfo) {
        guard viewControllers.isEmpty || enableForceUpdate else {
            return
        }
        enableDebugLog = options.enableDebugLog
        if UIDevice.current.userInterfaceIdiom == .pad {
            let rootViewController = PadCaptureViewController(options: options)
            rootViewController.delegate = self
            rootViewController.trackObserver = self
            viewControllers = [rootViewController]
        } else {
            let rootViewController = CaptureViewController(options: options)
            rootViewController.delegate = self
            rootViewController.trackObserver = self
            viewControllers = [rootViewController]
        }
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
