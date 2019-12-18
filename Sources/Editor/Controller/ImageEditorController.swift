//
//  PhotoEditorController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit
import SnapKit

public protocol ImageEditorControllerDelegate: class {
    
    func imageEditorDidCancel(_ editor: ImageEditorController)
    func imageEditor(_ editor: ImageEditorController, didFinishEditing photo: UIImage, isEdited: Bool)
    func imageEditor(_ editor: ImageEditorController, didFinishEditing video: URL, isEdited: Bool)
}

extension ImageEditorControllerDelegate {
    
    public func imageEditorDidCancel(_ editor: ImageEditorController) {
        editor.dismiss(animated: true, completion: nil)
    }
    public func imageEditor(_ editor: ImageEditorController, didFinishEditing photo: UIImage, isEdited: Bool) { }
    public func imageEditor(_ editor: ImageEditorController, didFinishEditing video: URL, isEdited: Bool) { }
}

open class ImageEditorController: UINavigationController {
    
    open weak var editorDelegate: ImageEditorControllerDelegate?
    
    open var tag: Int = 0
    
    private let manager: EditorManager = .init()
    
    /// Init image editor
    required public init(image: UIImage, config: PhotoConfig = .init(), delegate: ImageEditorControllerDelegate) {
        enableDebugLog = config.enableDebugLog
        super.init(nibName: nil, bundle: nil)
        check(config: config)
        self.manager.image = image
        self.manager.photoConfig = config
        self.editorDelegate = delegate
        
        let rootViewController = PhotoEditorController(manager: manager)
        rootViewController.delegate = self
        self.viewControllers = [rootViewController]
    }
    
    /// Init video editor
    required public init(video resource: VideoResource, config: VideoConfig = .init(), delegate: ImageEditorControllerDelegate) {
        enableDebugLog = config.enableDebugLog
        super.init(nibName: nil, bundle: nil)
        
        self.manager.videoResource = resource
        self.manager.videoConfig = config
        self.editorDelegate = delegate

        let rootViewController = VideoEditorController(manager: manager)
        rootViewController.delegate = self
        self.viewControllers = [rootViewController]
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

// MARK: - Private function
extension ImageEditorController {
    
    private func check(config: PhotoConfig) {
        assert(config.cacheIdentifier.firstIndex(of: "/") == nil, "Cache identifier can't contains '/'")
        assert(config.penColors.count <= 7, "Pen colors count can't bigger then 7")
        assert(config.mosaicOptions.count <= 5, "Mosaic count can't bigger then 5")
    }
}

// MARK: - PhotoEditorControllerDelegate
extension ImageEditorController: PhotoEditorControllerDelegate {
    
    func photoEditorDidCancel(_ editor: PhotoEditorController) {
        editorDelegate?.imageEditorDidCancel(self)
    }
    
    func photoEditor(_ editor: PhotoEditorController, didFinishEditing photo: UIImage, isEdited: Bool) {
        editorDelegate?.imageEditor(self, didFinishEditing: photo, isEdited: isEdited)
    }
}

// MARK: - VideoEditorControllerDelegate
extension ImageEditorController: VideoEditorControllerDelegate {
    
    func videoEditorDidCancel(_ editor: VideoEditorController) {
        
    }
    
    func videoEditor(_ editor: VideoEditorController, didFinishEditing video: URL, isEdited: Bool) {
        
    }
}
