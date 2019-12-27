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

open class ImageEditorController: AnyImageNavigationController {
    
    open private(set) weak var editorDelegate: ImageEditorControllerDelegate?
    
    /// Init image editor
    required public init(image: UIImage, config: PhotoConfig = .init(), delegate: ImageEditorControllerDelegate) {
        enableDebugLog = config.enableDebugLog
        super.init(nibName: nil, bundle: nil)
        check(config: config)
        self.editorDelegate = delegate
        let rootViewController = PhotoEditorController(image: image, config: config, delegate: self)
        self.viewControllers = [rootViewController]
    }
    
    /// Init video editor
    required public init(video resource: VideoResource, placeholdImage: UIImage?, config: VideoConfig = .init(), delegate: ImageEditorControllerDelegate) {
        enableDebugLog = config.enableDebugLog
        super.init(nibName: nil, bundle: nil)
        self.editorDelegate = delegate
        let rootViewController = VideoEditorController(resource: resource, placeholdImage: placeholdImage, config: config, delegate: self)
        self.viewControllers = [rootViewController]
    }
    
    @available(*, deprecated, message: "init(coder:) has not been implemented")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        editorDelegate?.imageEditorDidCancel(self)
    }
    
    func videoEditor(_ editor: VideoEditorController, didFinishEditing video: URL, isEdited: Bool) {
        
    }
}
